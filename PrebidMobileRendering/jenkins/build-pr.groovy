pipeline {
    agent none

    environment {
        JOB_ID = getJobId()
    }

    stages {

        stage('Build') {

            when { not { branch 'develop' } }
            agent { label 'mobile' }

            steps {
                sh 'hostname'
                dir('PrebidMobileRendering') {
                    sh('bundle install')
                    sh('bundle exec fastlane build_sdk')
                }
            }
            post {
                cleanup {
                    deleteDir()
                }
            }
        }

        stage('Unit Tests: Event Handlers') {

            when { not { branch 'develop' } }

            parallel {

                stage('Unit Tests: GAM EH [iPhone, iOS Previous]') {

                    agent { label 'mobile' }

                    steps {
                        sh 'hostname'
                        dir('PrebidMobileRendering') {
                            sh('bundle install')
                            sh('bundle exec fastlane UnitTests_GAM_EH_iOS_Previous')
                            dir('fastlane') {
                                sh("zip -rq '${STAGE_NAME} test_output.zip' test_output")
                            }
                        }
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'PrebidMobileRendering/fastlane/*_output.zip', fingerprint: true
                            junit 'PrebidMobileRendering/fastlane/test_output/**/report.junit'
                        }
                        cleanup {
                            deleteDir()
                        }
                    }
                }

                stage('Unit Tests: GAM EH [iPhone, iOS Latest]') {

                    agent { label 'mobile' }

                    steps {
                        sh 'hostname'
                        dir('PrebidMobileRendering') {
                            sh('bundle install')
                            sh('bundle exec fastlane UnitTests_GAM_EH_iOS_Latest')
                            dir('fastlane') {
                                sh("zip -rq '${STAGE_NAME} test_output.zip' test_output")
                            }
                        }
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'PrebidMobileRendering/fastlane/*_output.zip', fingerprint: true
                            junit 'PrebidMobileRendering/fastlane/test_output/**/report.junit'
                        }
                        cleanup {
                            deleteDir()
                        }
                    }
                }
            }
        }

        stage('Unit Tests: Apollo SDK') {
            when { not { branch 'develop' } }

            parallel {
                stage('Unit Tests: Apollo SDK [iPhone, iOS Previous]') {

                    agent { label 'mobile' }

                    steps {
                        sh 'hostname'
                        dir('PrebidMobileRendering') {
                            sh('bundle install')
                            sh('bundle exec fastlane UnitTests_SDK_iOS_Previous')
                            dir('fastlane') {
                                sh("zip -rq '${STAGE_NAME} test_output.zip' test_output")
                            }
                        }
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'PrebidMobileRendering/fastlane/*_output.zip', fingerprint: true
                            junit 'PrebidMobileRendering/fastlane/test_output/**/report.junit'
                        }
                        cleanup {
                            deleteDir()
                        }
                    }
                }

                stage('Unit Tests: Apollo SDK [iPhone, iOS Latest]') {

                    agent { label 'mobile' }

                    environment {
                        GIT_COMMIT_SHORT = sh(script: "printf \$(git rev-parse --short ${GIT_COMMIT})", returnStdout: true).trim()
                    }
                    steps {
                        sh 'hostname'
                        dir('PrebidMobileRendering') {
                            sh('bundle install')
                            sh('bundle exec fastlane UnitTests_SDK_iOS_Latest report_coverage:true')
                            dir('fastlane') {
                                sh("zip -rq '${STAGE_NAME} test_output.zip' test_output")
                                sh("zip -rq '${STAGE_NAME} xcov_output.zip' xcov_output")
                            }
                        }
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'PrebidMobileRendering/fastlane/*_output.zip', fingerprint: true
                            junit 'PrebidMobileRendering/fastlane/test_output/**/report.junit'
                        }
                        cleanup {
                            deleteDir()
                        }
                    }
                }
            }
        }

        stage('UI Tests') {
            when { not { branch 'develop' } }

            parallel {

                stage('UI Tests: Internal Test App [iPhone, iOS Latest]') {

                    agent { label 'mobile' }

                    environment {
                        GIT_COMMIT_SHORT = sh(script: "printf \$(git rev-parse --short ${GIT_COMMIT})", returnStdout: true).trim()
                    }
                    steps {
                        sh 'hostname'
                        dir('PrebidMobileRendering') {
                            sh('git clone git@github.com:openx/mobile-mock-server.git')
                            sh('mobile-mock-server/install.sh')
                            sh('python3 mobile-mock-server/manage.py makemigrations')
                            sh('python3 mobile-mock-server/manage.py migrate')
                            sh('python3 mobile-mock-server/manage.py runserver_plus 10.0.2.2:8000 --cert-file mobile-mock-server/emulator.crt &')
                            sh('bundle install')

                            sh('bundle exec fastlane UITests_InternalTestApp')
                            dir('fastlane') {
                                sh("zip -rq '${STAGE_NAME} test_output.zip' test_output")
                            }
                        }
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'PrebidMobileRendering/fastlane/*_output.zip', fingerprint: true
                            junit 'PrebidMobileRendering/fastlane/test_output/**/report.junit'
                        }
                        cleanup {
                            deleteDir()
                        }
                    }
                }
            }
        }

    //     stage('Delivery apps for QA') {
    //
    //         when { branch 'develop' }
    //
    //         parallel {
    //             stage('Distribute OpenXInternalTestApp') {
    //
    //                 agent { label 'mobile' }
    //
    //                 steps {
    //                     sh 'hostname'
    //                     dir('PrebidMobileRendering') {
    //                         sh 'bundle install'
    //                         sh 'bundle exec pod deintegrate EventHandlers/EventHandlers.xcodeproj'
    //                         sh 'bundle exec pod deintegrate OpenXInternalTestApp/OpenXInternalTestApp/OpenXInternalTestApp.xcodeproj'
    //                         sh 'mv Podfile Podfile.bck'
    //                         sh 'sed "/platform :ios, \'9.0\'/d" < Podfile.bck > Podfile'
    //                         sh 'bundle exec pod install --repo-update'
    //                         sh 'bundle exec fastlane distribute_internal_test_app branch_name:${GIT_BRANCH}'
    //                     }
    //                 }
    //                 post {
    //                     cleanup {
    //                         deleteDir()
    //                     }
    //                 }
    //             }
    //
    //             stage('Distribute PrebidApp') {
    //
    //                 agent { label 'mobile' }
    //
    //                 steps {
    //                     sh 'hostname'
    //                     dir('PrebidMobileRendering') {
    //                         sh('bundle install')
    //                         sh('bundle exec fastlane distribute_prebid_app')
    //                     }
    //                 }
    //                 post {
    //                     cleanup {
    //                         deleteDir()
    //                     }
    //                 }
    //             }
    //
    //             stage('Distribute IAB Certification App') {
    //
    //                 agent { label 'mobile' }
    //
    //                 steps {
    //                     sh 'hostname'
    //                     dir('PrebidMobileRendering') {
    //                         sh('bundle install')
    //                         sh('bundle exec fastlane distribute_certification_app')
    //                     }
    //                 }
    //                 post {
    //                     cleanup {
    //                         deleteDir()
    //                     }
    //                 }
    //             }
    //         }
    //     }
    }
}

def getJobId() {
    String datePart = new Date().format('yyyyMMddHHmmss')
    int randomInt = new Random().nextInt((int) 9e7) + (int) 1e7
    return datePart + "-" + randomInt.toString()
}
