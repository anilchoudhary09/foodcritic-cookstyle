// Jenkinsfile - Dynamic Cookstyle Pipeline for Chef Cookbook Validation
//
// This pipeline validates cookbooks against:
// 1. Standard Cookstyle rules (200+ Chef best practices)
// 2. Custom BARC rules (organization security policies)
//
// Usage: Select cookbook from dropdown when running "Build with Parameters"

pipeline {
    agent any

    parameters {
        choice(
            name: 'COOKBOOK_NAME',
            choices: ['my-app-cookbook', 'compliant-cookbook'],
            description: 'Select the cookbook to validate with Cookstyle'
        )
        booleanParam(
            name: 'FAIL_ON_VIOLATIONS',
            defaultValue: true,
            description: 'Fail the build if violations are found'
        )
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 15, unit: 'MINUTES')
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Validating cookbook: ${params.COOKBOOK_NAME}"
            }
        }

        stage('Setup') {
            steps {
                sh """
                    echo "Ruby version: \$(ruby --version)"
                    echo "Cookstyle version: \$(cookstyle --version)"
                    echo ""
                    echo "Selected Cookbook: ${params.COOKBOOK_NAME}"
                """
            }
        }

        stage('Cookstyle Lint') {
            steps {
                script {
                    def cookbookPath = "cookbooks/${params.COOKBOOK_NAME}"

                    sh """
                        echo "╔═══════════════════════════════════════════════════════════╗"
                        echo "║           COOKSTYLE ANALYSIS: ${params.COOKBOOK_NAME}"
                        echo "╚═══════════════════════════════════════════════════════════╝"

                        cd ${cookbookPath}

                        # Run cookstyle - BARC rules loaded via .rubocop.yml inherit_from
                        cookstyle . \\
                            --format progress \\
                            --format json --out cookstyle-report.json || true

                        # Generate beautiful HTML report
                        if [ -f cookstyle-report.json ]; then
                            ruby ../my-app-cookbook/scripts/generate_report.rb cookstyle-report.json > cookstyle-report.html
                            echo "HTML Report generated successfully"
                        fi
                    """
                }
            }
        }

        stage('Analyze Results') {
            steps {
                script {
                    def cookbookPath = "cookbooks/${params.COOKBOOK_NAME}"
                    def reportPath = "${cookbookPath}/cookstyle-report.json"

                    if (fileExists(reportPath)) {
                        // Parse JSON using Ruby (no additional plugins needed)
                        def resultOutput = sh(
                            script: """
                                cd ${cookbookPath}
                                ruby -rjson -e '
                                    report = JSON.parse(File.read("cookstyle-report.json"))
                                    summary = report["summary"]

                                    errors = 0
                                    warnings = 0
                                    conventions = 0
                                    barc_violations = {}
                                    chef_violations = {}

                                    report["files"].each do |file|
                                        file["offenses"].each do |offense|
                                            case offense["severity"]
                                            when "error", "fatal"
                                                errors += 1
                                            when "warning"
                                                warnings += 1
                                            else
                                                conventions += 1
                                            end

                                            cop = offense["cop_name"]
                                            if cop.start_with?("Barclays/")
                                                barc_violations[cop] = (barc_violations[cop] || 0) + 1
                                            else
                                                chef_violations[cop] = (chef_violations[cop] || 0) + 1
                                            end
                                        end
                                    end

                                    status = errors > 0 ? "FAIL" : "PASS"

                                    puts "FILES_INSPECTED=#{summary["inspected_file_count"]}"
                                    puts "TOTAL_OFFENSES=#{summary["offense_count"]}"
                                    puts "ERRORS=#{errors}"
                                    puts "WARNINGS=#{warnings}"
                                    puts "CONVENTIONS=#{conventions}"
                                    puts "STATUS=#{status}"

                                    if barc_violations.any?
                                        puts "BARC_VIOLATIONS:"
                                        barc_violations.sort_by { |k, v| -v }.each { |cop, count| puts "  #{count} - #{cop}" }
                                    end

                                    if chef_violations.any?
                                        puts "CHEF_VIOLATIONS:"
                                        chef_violations.sort_by { |k, v| -v }.take(5).each { |cop, count| puts "  #{count} - #{cop}" }
                                    end
                                '
                            """,
                            returnStdout: true
                        ).trim()

                        // Parse the output
                        def lines = resultOutput.split('\n')
                        def errors = 0
                        def warnings = 0
                        def filesInspected = 0
                        def totalOffenses = 0
                        def status = "PASS"

                        lines.each { line ->
                            if (line.startsWith('ERRORS=')) errors = line.split('=')[1].toInteger()
                            if (line.startsWith('WARNINGS=')) warnings = line.split('=')[1].toInteger()
                            if (line.startsWith('FILES_INSPECTED=')) filesInspected = line.split('=')[1].toInteger()
                            if (line.startsWith('TOTAL_OFFENSES=')) totalOffenses = line.split('=')[1].toInteger()
                            if (line.startsWith('STATUS=')) status = line.split('=')[1]
                        }

                        echo """
╔═══════════════════════════════════════════════════════════╗
║              COOKSTYLE ANALYSIS RESULTS                   ║
╠═══════════════════════════════════════════════════════════╣
║  Cookbook:         ${params.COOKBOOK_NAME}
║  Status:           ${status}
║  ─────────────────────────────────────────────────────────║
║  Files Inspected:  ${filesInspected}
║  Total Offenses:   ${totalOffenses}
║  ─────────────────────────────────────────────────────────║
║  Errors:           ${errors}
║  Warnings:         ${warnings}
╚═══════════════════════════════════════════════════════════╝
"""

                        // Show violation details
                        def inBarcSection = false
                        def inChefSection = false
                        lines.each { line ->
                            if (line == 'BARC_VIOLATIONS:') {
                                echo "BARC Security Violations:"
                                inBarcSection = true
                                inChefSection = false
                            } else if (line == 'CHEF_VIOLATIONS:') {
                                echo "Chef Best Practice Violations:"
                                inChefSection = true
                                inBarcSection = false
                            } else if ((inBarcSection || inChefSection) && line.startsWith('  ')) {
                                echo line
                            } else {
                                inBarcSection = false
                                inChefSection = false
                            }
                        }

                        // Handle build result
                        if (errors > 0 && params.FAIL_ON_VIOLATIONS) {
                            currentBuild.result = 'FAILURE'
                            error "Build failed: Found ${errors} error-level violations in ${params.COOKBOOK_NAME}"
                        } else if (warnings > 0) {
                            currentBuild.result = 'UNSTABLE'
                            echo "Build unstable: Found ${warnings} warnings"
                        } else if (totalOffenses == 0) {
                            echo "${params.COOKBOOK_NAME} passed all checks!"
                        }
                    } else {
                        error "Report file not found: ${reportPath}"
                    }
                }
            }
        }
    }

    post {
        always {
            // Archive reports
            archiveArtifacts artifacts: "cookbooks/${params.COOKBOOK_NAME}/cookstyle-report.*", allowEmptyArchive: true

            // Publish HTML report
            publishHTML(target: [
                allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: "cookbooks/${params.COOKBOOK_NAME}",
                reportFiles: 'cookstyle-report.html',
                reportName: "Cookstyle Report - ${params.COOKBOOK_NAME}"
            ])
        }

        success {
            echo """
╔═══════════════════════════════════════════════════════════╗
║  BUILD SUCCESS                                            ║
║  Cookbook: ${params.COOKBOOK_NAME}
╚═══════════════════════════════════════════════════════════╝
            """
        }

        unstable {
            echo """
╔═══════════════════════════════════════════════════════════╗
║  BUILD UNSTABLE - Warnings found                          ║
║  Cookbook: ${params.COOKBOOK_NAME}
║  Review the Cookstyle Report for details                  ║
╚═══════════════════════════════════════════════════════════╝
            """
        }

        failure {
            echo """
╔═══════════════════════════════════════════════════════════╗
║  BUILD FAILED - Violations detected                       ║
║  Cookbook: ${params.COOKBOOK_NAME}
║  Review the Cookstyle Report for details                  ║
╚═══════════════════════════════════════════════════════════╝
            """
        }
    }
}
