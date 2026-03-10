// Jenkinsfile - Cookstyle Pipeline for Chef Cookbook Validation
//
// This pipeline validates cookbooks against:
// 1. Standard Cookstyle rules (200+ Chef best practices)
// 2. Custom BARC rules (organization security policies)

pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 15, unit: 'MINUTES')
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Checked out: ${env.GIT_COMMIT}"
            }
        }

        stage('Setup') {
            steps {
                sh '''
                    echo "Ruby version: $(ruby --version)"
                    echo "Bundler version: $(bundle --version)"

                    # Install dependencies in my-app-cookbook
                    cd cookbooks/my-app-cookbook

                    # Remove old lockfile to avoid Ruby 3.2 compatibility issues
                    rm -f Gemfile.lock

                    bundle install --jobs 4
                '''
            }
        }

        stage('Cookstyle Lint') {
            steps {
                script {
                    // Run cookstyle and capture exit code
                    def exitCode = sh(
                        script: '''
                            echo "╔═══════════════════════════════════════════════════════════╗"
                            echo "║           RUNNING COOKSTYLE ANALYSIS                      ║"
                            echo "╚═══════════════════════════════════════════════════════════╝"

                            cd cookbooks/my-app-cookbook
                            bundle exec cookstyle . \
                                --format progress \
                                --format json --out cookstyle-report.json \
                                --format html --out cookstyle-report.html
                        ''',
                        returnStatus: true
                    )

                    env.COOKSTYLE_EXIT_CODE = exitCode.toString()

                    if (exitCode != 0) {
                        echo "⚠️  Cookstyle found violations (exit code: ${exitCode})"
                    } else {
                        echo "✅ Cookstyle passed with no violations"
                    }
                }
            }
        }

        stage('Analyze Results') {
            steps {
                script {
                    if (fileExists('cookbooks/my-app-cookbook/cookstyle-report.json')) {
                        def report = readJSON file: 'cookbooks/my-app-cookbook/cookstyle-report.json'
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

                        echo """
╔═══════════════════════════════════════════════════════════╗
║              COOKSTYLE ANALYSIS RESULTS                   ║
╠═══════════════════════════════════════════════════════════╣
║  Files Inspected:  ${summary.inspected_file_count.toString().padLeft(5)}                                 ║
║  Total Offenses:   ${summary.offense_count.toString().padLeft(5)}                                 ║
║  ─────────────────────────────────────────                ║
║  🔴 Errors:        ${errors.toString().padLeft(5)}                                 ║
║  🟡 Warnings:      ${warnings.toString().padLeft(5)}                                 ║
║  🔵 Conventions:   ${conventions.toString().padLeft(5)}                                 ║
╚═══════════════════════════════════════════════════════════╝
                        """

                        // List top violations
                        def violationsByType = [:]
                        report.files.each { file ->
                            file.offenses.each { offense ->
                                def cop = offense.cop_name
                                violationsByType[cop] = (violationsByType[cop] ?: 0) + 1
                            }
                        }

                        if (violationsByType.size() > 0) {
                            echo "Top Violations:"
                            violationsByType.sort { -it.value }.take(10).each { cop, count ->
                                echo "  ${count.toString().padLeft(3)} - ${cop}"
                            }
                        }

                        // Fail build on errors
                        if (errors > 0) {
                            currentBuild.result = 'FAILURE'
                            error "❌ Build failed: Found ${errors} error-level violations"
                        } else if (warnings > 0) {
                            currentBuild.result = 'UNSTABLE'
                            echo "⚠️  Build unstable: Found ${warnings} warnings"
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            // Archive reports
            archiveArtifacts artifacts: 'cookbooks/my-app-cookbook/cookstyle-report.*', allowEmptyArchive: true

            // Publish HTML report (requires HTML Publisher plugin)
            publishHTML(target: [
                allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'cookbooks/my-app-cookbook',
                reportFiles: 'cookstyle-report.html',
                reportName: 'Cookstyle Report'
            ])

            // Clean workspace
            cleanWs(cleanWhenSuccess: true, cleanWhenFailure: false)
        }

        success {
            echo '''
╔═══════════════════════════════════════════════════════════╗
║  ✅ BUILD SUCCESS - Cookbook passed all validations       ║
╚═══════════════════════════════════════════════════════════╝
            '''
        }

        unstable {
            echo '''
╔═══════════════════════════════════════════════════════════╗
║  ⚠️  BUILD UNSTABLE - Warnings found, review report       ║
╚═══════════════════════════════════════════════════════════╝
            '''
        }

        failure {
            echo '''
╔═══════════════════════════════════════════════════════════╗
║  ❌ BUILD FAILED - Critical violations found              ║
║     Review cookstyle-report.html for details              ║
╚═══════════════════════════════════════════════════════════╝
            '''
        }
    }
}
