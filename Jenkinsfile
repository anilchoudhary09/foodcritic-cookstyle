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
                        
                        # Run cookstyle and generate JSON report
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
                    def reportPath = "cookbooks/${params.COOKBOOK_NAME}/cookstyle-report.json"
                    
                    if (fileExists(reportPath)) {
                        def report = readJSON file: reportPath
                        def summary = report.summary

                        // Count by severity
                        def errors = 0
                        def warnings = 0
                        def conventions = 0

                        report.files.each { file ->
                            file.offenses.each { offense ->
                                switch(offense.severity) {
                                    case 'error':
                                    case 'fatal':
                                        errors++
                                        break
                                    case 'warning':
                                        warnings++
                                        break
                                    default:
                                        conventions++
                                }
                            }
                        }

                        // Determine status
                        def status = errors > 0 ? 'FAIL' : 'PASS'
                        
                        echo """
╔═══════════════════════════════════════════════════════════╗
║              COOKSTYLE ANALYSIS RESULTS                   ║
╠═══════════════════════════════════════════════════════════╣
║  Cookbook:         ${params.COOKBOOK_NAME}
║  Status:           ${status}
║  ─────────────────────────────────────────                ║
║  Files Inspected:  ${summary.inspected_file_count}
║  Total Offenses:   ${summary.offense_count}
║  ─────────────────────────────────────────                ║
║  Errors:           ${errors}
║  Warnings:         ${warnings}
║  Conventions:      ${conventions}
╚═══════════════════════════════════════════════════════════╝
                        """

                        // List BARC violations separately
                        def barcViolations = [:]
                        def chefViolations = [:]
                        
                        report.files.each { file ->
                            file.offenses.each { offense ->
                                if (offense.cop_name.startsWith('Barclays/')) {
                                    barcViolations[offense.cop_name] = (barcViolations[offense.cop_name] ?: 0) + 1
                                } else {
                                    chefViolations[offense.cop_name] = (chefViolations[offense.cop_name] ?: 0) + 1
                                }
                            }
                        }

                        if (barcViolations.size() > 0) {
                            echo "BARC Security Violations:"
                            barcViolations.sort { -it.value }.each { cop, count ->
                                echo "   ${count} - ${cop}"
                            }
                        }

                        if (chefViolations.size() > 0) {
                            echo "Chef Best Practice Violations:"
                            chefViolations.sort { -it.value }.take(5).each { cop, count ->
                                echo "   ${count} - ${cop}"
                            }
                        }

                        // Handle build result
                        if (errors > 0 && params.FAIL_ON_VIOLATIONS) {
                            currentBuild.result = 'FAILURE'
                            error "Build failed: Found ${errors} error-level violations in ${params.COOKBOOK_NAME}"
                        } else if (warnings > 0) {
                            currentBuild.result = 'UNSTABLE'
                            echo "Build unstable: Found ${warnings} warnings"
                        } else if (summary.offense_count == 0) {
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
