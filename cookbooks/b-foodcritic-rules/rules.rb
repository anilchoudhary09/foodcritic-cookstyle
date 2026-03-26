@system_services = %w[
  # UNIX
  dhcpd
  galaxy
  gmond
  ifdhandler
  mdmonitor
  messagebus
  multipathd
  network
  nfsd
  nscd
  nslcd
  ntpd
  oddjobd
  openssh-daemon
  pcscd
  portreserve
  quota_nld
  rdisc
  rngd
  rpc.gssd
  rpc.idmapd
  rpc.mountd
  rpc.rquotad
  rpc.statd
  rpc.svcgssd
  rpcbind
  rsyslogd
  sandbox
  saslauthd
  sendmail
  smartd
  smb
  sm-client
  snmpd
  snmptrapd
  sshd
  sssd
  tcsd
  trace-cmd
  tuned
  uuidd
  vasd
  vsftpd
  winbindd
  ypbind
  # Windows
  ccmexec
  eventlog
  eventsystem
  galaxycore
  galaxywdsagent
  mpssvc
  netlogon
  policyagent
  rpcss
  samss
  sepmasterservice
  splunkforwarder
  winmgmt
]

@restricted_attributes = {
  'enable_custom_sudoers_policies' => ['is_uisec_unix_sudo', # CHG1003820708
                                       'is_mw_tomcat8_build2018', # CHG1003888716
                                       'is_mw_tomcat_build2018', # CHG1003888716
                                       'is_mw_apachehttpd_build2018', # CHG1003888716
                                       'is_mw_jboss7_build02', # CHG1003888716
                                       'is_mw_gridgain_build02', # CHG1003888716
                                       'is_mw_jwstomcat9_build02', # CHG1003888716
                                       'is_iaas_rhel_base', # CHG1005551436
                                       'is_iaas_aix_base'] # CHG1010065051

}

# CHG1001644020 to invert logic. Convert whitelist to the restricted services
# Any unseen service will be treated as valid unless restricted here for specified cookbook(s)
@restricted_services = {
  # whitelisted for any cookbook
  'aws-configurator' => [],                                 # CHNG0003722139 OS2AWS AWS Configurator application startup script
  'aws-nameservice' => [],                                  # CHNG0003722139 cto-iaas-aws-nameservice
  'aws-registry' => [],                                     # CHNG0003722139 OS2AWS AWS Registry application startup script
  'azure-agent' => [],                                      # CHNG0003894857 bci_lab_azure_agent
  'cft_splunk' => [],                                       # CHNG0003861518 cft_splunk
  'cft_splunk_watchdog' => [],                              # CHNG0003861518 cft_splunk_watchdog
  'consul' => [],                                           # CHNG0003722139 bc-devops-elk-dev-elk
  'docker' => [], # CHG1001550657
  'elasticsearch' => [],                                    # CHNG0003722139 bc-devops-elk-dev-elk
  'executionagent-' => [],                                  # CHNG0003814211 pcb-lab-generic-dev-barc_middleware_execapi
  'filebeat' => [], # CHG1001174028
  'gis_splunk' => [],                                       # CHNG0003803732 is-mw-splunk-install
  'jboss-standalone' => [],                                 # CHNG0003803732 is-mw-jboss6-build
  'jenkins' => [],                                          # CHNG0003635085 b-jenkins-rolb
  'jenkins-slave' => [],                                    # CHG1001550657 automate jenkins installations
  'jenkins_slave' => [],                                    # CHG1001550657 automate jenkins installations
  'kibana4' => [],                                          # CHNG0003722139 bc-devops-elk-dev-elk
  'logstash-elklogstash_indexer_type' => [],                # CHNG0003722139 bc-devops-elk-dev-elk
  'mariadb' => [],                                          # CHG1001550657 mysql fork
  'memcached' => [],                                        # CHNG0004036486 caching service for aws-registry, aws-nameservice, aws-configurator
  'metricbeat' => [], # CHG1001174041
  'mongod' => [],                                           # CHG1001550657 NoSQL database
  'mysql' => [],
  'mysqld' => [],
  'nginx16-nginx' => [],                                    # CHNG0003861518 nginx16-nginx
  'nrpe' => [],                                             # CHNG0003803732 rolb-env-nagios-client
  'os2aws-nameservice' => [],                               # CHNG0003722139 OS2AWS AWS NameService instance startup script
  'os2aws-supervisor' => [],                                # CHNG0003722139 OS2AWS Bridge startup script
  'pdweb' => [],                                            # CHNG0003989307 WebSEAL service ,IT Sec project
  'postgresql-9.6' => [],                                   # CHG1001619527
  'sprg-' => [],                                            # CHG1000503188 GRPCIBDCOR-249 spring service for proputils
  'tcagent' => [], # CHG1001562605
  'teamcity' => [],                                         # CHG1001619527
  'telegraf' => [],                                         # CHG1001550657 agent for collecting, processing, aggregating, and writing metrics
  'influxdb.service' => %w[ib_rft_influxdb_bdh ib_rft_unix_bdh], # CHG1009157746 InfluxDB service for new InfluxDB BDH cookbook
  'grafana-server.service' => %w[ib_rft_grafana_bdh ib_rft_unix_bdh], # CHG1009370153 Grafana service for new Grafana BDH cookbook
  'tomcat' => [],
  'tomcat7-' => [],                                         # CHNG0003832319 is-mw-tomcat-build
  'tomcat@' => [],                                          # CHNG0003832319 is-mw-tomcat-build
  'tomcat_6_0_redhat' => [],                                # CHNG0003832319 is-mw-tomcat-build
  'vault' => [],                                            # CHNG0003668914 b-vault
  'logstash' => [],                                         # CHG1001516703 bi_esaas_core_logstash
  'kibana' => [],                                           # CHNG0004391565 bsd_devops_elk_gru_kibana
  'zookeeper' => [],                                        # CHG1001284368
  'kafka' => [],                                            # CHG1001225840
  'kafka-connect' => [],                                    # CHG1001114164
  'aerospike' => [],                                        # CHG1000366118
  'solr' => [],                                             # CHG1001245392
  'squid' => [],                                            # CHG1001494481
  'nfs-server' => [],                                       # CHNG0004735348
  'haproxy' => [],                                          # CHG1000300493
  'etcd' => [],                                             # CHNG0004823883

  # Infrastructure, Server team services
  'is_iaas_unix_syslogservice' => ['is_iaas_unix_syslog'], # CHNG0003824687 is_iaas_unix_syslog
  'rsyslog' => ['is-apaaseng-osev3-b-openshift3_enterprise',       # CHNG0004037516
                'is_apaasengosev3_bopenshift3enterprise_dev',      # CHNG0004735348
                'is_apaasengosev3_bopenshift3enterprise_devuat',   # CHNG0004735348
                'is_apaasengosev3_bopenshift3enterprise_pilot',    # CHNG0004735348
                'is_mw_splunkloggingandmonitoringfor_jbosslegacy', # CHNG0004707297
                'cto_arch_kama_cookbook',                          # CHG1000672597
                'is_mw_iib10_build',                               # CHNG0004714007
                'is_mw_ace_build',                                 # CHG1008241054
                'cso_sets_logsec_splunk'],                         # CHG1004842122
  'firewalld' => ['is_apaas_openshift_cookbook', # CHNG0004823883
                  'is_iaas_unix_network'], # CHG1001550657 infrastructure cookbook to manage network
  'schedule' => ['b_win_all_chefclientconfig'], # CHNG0004124180
  'besclient' => ['iaas_unix_ilmt_agent',	# CHNG0004266773
                  'gtsm_ssm_ilmt_agent'],	# CHG1014155756
  'xinetd' => ['coo_bcdcm_cvs_app',                          # CHG1002585008
               'is_mw_checkmk_agent'],                       # CHNG0004275345
  'Domain Time Client' => ['b_win_all_domaintime'], # CHNG0004307555
  'TaniumClient' => ['insv_eme_tanium_client'], # CHNG0004449386
  'taniumclient' => ['insv_eme_tanium_client'], # CHNG0004624252
  'winrm' => ['b_win_all_platformsettings', # CHNG0004632094
              'b_win_all_secbaseline'], # CHG1003402726
  'stisvc' => ['b_win_all_platformsettings', # CHNG0004632094
               'b_win_all_secbaseline'], # CHG1003402726
  'nessusagent' => ['is_va_tenable_deploy', # CHNG0005030215
		    'cso_gisva_nessusagentupgrade_linux', # CHG1019864456
                    'cso_gisva_nessusagent_linux'], # CHG1002673176
  'dnsmasq' => ['is-apaaseng-osev3-b-openshift3_enterprise', # CHNG0005058750
                'is_apaasengosev3_bopenshift3enterprise_dev', # CHNG0005058750
                'is_apaasengosev3_bopenshift3enterprise_devuat', # CHNG0005058750
                'is_apaasengosev3_bopenshift3enterprise_pilot', # CHNG0005058750
                'is_apaas_openshift_cookbook'], # CHNG0005058750
  'kdump' => ['gtis_unix_kdump_client', # CHNG0005255084
              'rft_basis_sap_hana'], # CHG1001320435
  'usbguard' => ['gtis_unix_usb_disable'], # CHG1000361051
  'galaxy' => ['is_cto_awsbuild_rhel'], # CHG1000417605
  'gmond' => ['is_cto_awsbuild_rhel'], # CHG1000417605
  'BCnimbus' => ['is_cto_awsbuild_rhel'], # CHG1000417605
  'vasd' => ['is_cto_awsbuild_rhel'], # CHG1000417605
  'lvm2-lvmetad' => ['b_iac_cc_lvm'], # CHG1000448720
  'named' => ['gtis_swift_sag_build', # CHG1000612714
              'azlan_sharedsvc_connectivity_dns'], # CHG1004735802
  'pcsd' => ['is_iaas_pacemaker_setuppcs'], # CHG1001598651 pcsd daemon enable and startup (is_iaas_pacemaker_setuppcs )
  'steward' => ['is_iaas_unix_steward'], # CHG1001135235
  'tet-sensor' => ['b_unix_netseg_tetration'], # CHG1001619329 CISCO Tetration Agent Service tet-sensor
  'pipeline-ui-' => %w[is_iaas_chefpipeline_install gtis_chef_infrastructure_pipelineproxy], # CHG1001647459 Chef PipelineUI deployment

  # Application Cookbook Pipeline services
  'bpsauths_tomcat_' => ['bps_devops_bpsauths_tomcat'],     # CHG1000370691 tomcat resource library bps_devops_bpsauths_tomcat
  'bpsauths_activemq_' => ['bps_devops_bpsauths_activemq'], # CHG1000370691 activemq resource library bps_devops_bpsauths_activemq
  'bpsauths_datastax_' => ['app_bpsauths_datastax'],        # CHG1000649321 datastax cassandra service from bpsauths cookbook wrap_bpsauths_datastax
  'bpsauths_authentic_' => ['app_bpsauths_authentic'],      # CHG1001128653 NCR authentic service from bpsauths cookbook app_bpsauths_authentic
  'bpsauths_nginx_' => ['app_bpsauths_nginx'],              # CHG1001421539 nginx service from bpsauths cookbook app_bpsauths_nginx
  'dockersampleapp' => ['app_testchef'], # CHG1000476135

  # Misc services
  'salt-minion' => ['rolb_env_salt_minion'], # CHNG0004033125 Salt minion service rolb_env_salt_minion
  'appian-jboss' => ['bc_devops_appian', # CHNG0004184033
                     'bc_devops_appian_core'], # CHNG0004643995
  'appian-engine' => ['bc_devops_appian', # CHNG0004184033
                      'bc_devops_appian_core'], # CHNG0004643995
  'appian-search-server' => ['bc_devops_appian', # CHNG0004184033
                             'bc_devops_appian_core'], # CHNG0004643995
  'microservice' => ['gis_cs_unix_microsvc'], # CHNG0004372653
  'authenticator' => ['gis_fc2_unix_microauth'], # CHNG0004382196
  'iscd-api' => ['bci_arch_strainno_iscd_install'], # CHNG0004424958
  'cft_mariadb_server' => ['cft_research_mariadb_server', # CHNG0004521470 MariaDB Server start script
                           'cft_wps_mariadb_server'], # CHNG0004521828
  'iq' => ['ib_cto_nexus_2'], # CHG1001110214
  'nexus' => ['is_cto_nexus_install',       # CHNG0004525607
              'is_apaas_nexus_install',     # CHNG0004927794
              'ib_cto_repo_nexus3_cookbook', # CHNG0004607621
              'ib_cto_nexus_2', # CHG1000221786
              'ib_cto_repo_nexus3', # CHNG0005065532
              'bsd_esaas_gru_ece', # CHG1000227966
              'bsd_esaas_gru_nexus', # CHG1000592844
              'ib_eqdevops_apps_base', # CHG1001599540
              'ib_qa_infra_standard'], # CHG1001521900
  'pm2' => ['gtis_dbaas_pm2_cookbook', # CHNG0004589721
            'bci_devops_core_nodejs'], # CHNG0004620040
  'sonarqube' => ['ib_cto_sonar_snq'], # CHNG0004631647
  # Approval required to whitelist service bitbucket  from Alan.Henstock-Mawer@barclayscorp.com
  'bitbucket' => ['ib_eqdevops_apps_base', # CHG1001619527
                  'dx_repotools_bitbucket_rhel'], # CHG1001888044
  'confluence' => ['ib_eqdevops_apps_base', # CHG1001619527
                   'dx_engineering_confluence_unix'], # CHG1001597088
  'jira' => ['ib_eqdevops_apps_base'], # CHG1001619527
  # Approval required to whitelist service TCbuildAgent from vijaya.koganti@barclays.com
  'TCBuildAgent' => ['ib_cto_teamcity_agent', # CHG1001098809
                     'ib_eqdevops_tcagent_win', # CHG1001526381
                     'cto_dx_teamcity_agentunix', # CHG1001723010
                     'ib_eqdevops_tcagent_aws', # CHG1001199821
                     'dx_citools_agent_rhel', # CHG1001862970
                     'cto_dx_citools_agentrhel', # CHG1001807189
                     'dx_citools_agent_rhel8'], # CHG1011554704
  'TCBuildAgentKitchen' => ['ib_cto_teamcity_agent'], # CHNG0004672378
  'TeamCity' => ['ib_cto_teamcity_serverwin'], # CHNG0005176590
  'HPCConfigCollector.sh' => ['rna_hpc_grid_tools'], # CHNG0004787144
  'abkcd' => ['bci_arch_abinitiocoop_base', # CHNG0004809051
              'gtis_edi_ai_install', # CHNG0004901022
              'iit_awsecf_ai_install', # CHNG0005191882
              'dais_devops_mhub_dev'], # CHG1000477934
  'appdynamics-machine-agent' => ['bci_core_appd_agent', # CHNG0004980736
                                  'buk_transformation_appdynamics_orchestration', # CHG1001119359
                                  'ftc_fml_appdynamics_agent', # CHG1001139288
                                  'bi_rtbmonitoring_appdynamics_agent', # CHG1001516744
                                  'gtis_mon_appd_agent', # CHG1001622883
                                  'pcb_internet_appdynamics_ec', # CHG1002189879
                                  'apicto_devops_mon_appdfb'], # CHG1002492021
  'cae-' => ['gis_secdevops_cae_deploy'], # CHNG0005012756 updated with CHG1000424151
  'spark_service' => ['ftc_fml_feedzai_spark', # CHNG0005120335
                      'ucrm_sales_apache_spark'], # CHG1004743482
  'spark_worker_service' => ['ftc_fml_feedzai_spark', # CHNG0005120335
                             'ucrm_sales_apache_spark'], # CHG1004743482
  'message-router' => ['ftc_fml_feedzai_messagerouter'], # CHNG0005120335
  'feedzai-pulse' => ['ftc_fml_feedzai_pulse'], # CHNG0005120335
  'rabbitmq-server' => ['ftc_fml_feedzai_rabbitmq', # CHNG0005142065
                        'tc25_rft_cfa_rabbitmqrhel8'], # CHG1011783403
  'amc' => ['ftc_fml_platform_amc', # CHG1000577132
            'ftc_fml_platform_aerospike', # CHG1001075488
            'ftc_platform_aerospike_base'], # CHG1008103471
  'fraud-profile' => ['ftc_fml_service_generic'], # CHG1000752601
  'fdcs-debit-transaction' => ['ftc_fml_service_generic'], # CHG1000872888
  'confluent-control-center' => ['ftc_fml_confluent_kafka', # CHG1000366213
                                 'buk_bfa_aws_confluentkafka', # CHG1001883343
                                 'is_mw_kafka_build02'], # CHG1000967425
  'connect-distributed' => ['is_mw_kafka_build02'], # CHG1001052042
  'fmlservice' => ['ftc_fml_service_generic'], # CHG1000747988
  'evagent' => ['pcb_btsoemtools_evolven_agent'], # CHNG0005149305 pcb_btsoemtools_evolven_agent
  'zing-memory' => ['ftc_fml_feedzai_zing'], # CHNG0005155088
  'fml-' => ['ftc_fml_service_generic', # CHG1001105926
             'ftc_fml_platform_cookbookutil'], # CHG1001238906
  'jamf.tomcat8' => ['gtis_macos_jamfpro_inf'], # CHG1001240456
  'jamf.tomcat' => ['gtis_macos_jamfpro_infrhel8'], # CHG1016322082
  'numad' => ['rft_basis_sap_hana'], # CHG1001320435
  'zap_' => ['pcb_rolb_zap_install'], # CHG1001323578
  'cft_filebeat' => ['cft_wps_elk_filebeat', # CHG1001367279
                     'cft_wps_apache_solr'], # CHG1001986630
  'cft_metricbeat' => ['cft_wps_elk_metricbeat'], # CHG1002778979
  'pingfederate' => ['gis_tiaaengineering_tiaa_aws'], # CHG1001462456
  'byok-' => ['gis_caedev_byok_deploy'], # CHG1000351730 updated with CHG1000419819
  'stagejira' => ['gcto_devtools_jira_jira', # CHG1000365175
                  'devtools_dtag_jira_upg'], # CHG1000365175
  'opsware-agent' => ['gtis_dba_hpsa_agent'], # CHG1000429841
  'fairvalue-processor' => ['ib_cto_poc_fairvalue'], # CHG1000486030
  'kamailio' => ['cto_arch_kama_cookbook'], # CHG1000672597
  'ccib-avaya-realtime-prod-ccup1' => ['bci_ccib_wfm_avayaproducer'], # CHG1000942922 updated with CHG1003141563
  'ccib-avaya-realtime-prod-ccup2-1' => ['bci_ccib_wfm_avayaproducer'], # CHG1000942922 updated with CHG1003141563
  'ccib-avaya-realtime-prod-ccup2-2' => ['bci_ccib_wfm_avayaproducer'], # CHG1000942922 updated with CHG1003141563
  'ccib-avaya-realtime-prod-ccup2' => ['bci_ccib_wfm_avayaproducer'], # CHG1000942922 updated with CHG1003141563
  'ccib-rt-splitter-prod-ccup1-primary' => ['bci_ccib_wfm_avayaproducer'], # CHG1000942922 updated with CHG1003141563
  'ccib-rt-splitter-prod-ccup1-secondary' => ['bci_ccib_wfm_avayaproducer'], # CHG1000942922 updated with CHG1003141563
  'ccib-rt-splitter-prod-ccup2-1-primary' => ['bci_ccib_wfm_avayaproducer'], # CHG1000942922 updated with CHG1003141563
  'ccib-rt-splitter-prod-ccup2-1-secondary' => ['bci_ccib_wfm_avayaproducer'], # CHG1000942922 updated with CHG1003141563
  'ccib-rt-splitter-prod-ccup2-primary' => ['bci_ccib_wfm_avayaproducer'], # CHG1000942922 updated with CHG1003141563
  'ccib-rt-splitter-prod-ccup2-secondary' => ['bci_ccib_wfm_avayaproducer'], # CHG1000942922 updated with CHG1003141563
  'ccib-appd-machine-agent' => ['bci_ccib_wfm_appdynamics'], # CHG1000973123
  'resilient' => ['gis_fc2_anvil_systemd'], # CHG1001563161
  'anvil-tris' => ['gis_fc2_anvil_systemd'], # CHG1001563161
  'anvil-pnr' => ['gis_fc2_anvil_systemd'], # CHG1001563161
  'microservices' => ['gis_fc2_anvil_systemd'], # CHG1001563161
  'caliveapicreator' => ['cto_dxeng_caliveapicreator_nplinux'], # CHG1001586380
  'gtisobs' => ['gtis_obs_core_linux'], # CHG1010854557
  # Nolio services
  'cft_nolio_' => ['cft_wps_nolio_agent'], # CHNG0004781051
  'nolioAgent_' => ['comp_cbanker_nolio_agent', # CHG1000365130
                    'comp_odc_nolioagent_config'], # CHG1000365130

  # Splunk services
  'pcb_splunk' => ['pcb_splunk_appl015753_installforwarder'],	# CHNG0004857528 pcb_splunk_appl015753_installforwarder
  'splunk' => ['is_mw_splunklm_odsee',                      # CHNG0004636530 allow is_mw_splunklm_odsee for LINUX
               'is_mw_itim_compliance',                     # CHNG0004684085 allow is_mw_itim_compliance for LINUX
               'gis_fc2_splunk_forwarder',                  # CHG1001534251 allow gis_fc2_splunk_forwarder for LINUX
               'cso_sets_logsec_splunk'],                   # CHG1011830222 allow cso_sets_logsec_splunk for LINUX
  'splunkd' => ['is_mw_splunk_lm_was',                      # CHNG0004378723 is_mw_splunk_lm_was for AIX
                'is_mw_splunk_lm_cd',                       # CHNG0004392482 allow is_mw_splunk_lm_cd for AIX
                'is_mw_splunk_lm_cd_windows',               # CHNG0004473018 allow is_mw_splunk_lm_cd_windows
                'is_mw_splunk_lm_dtu',                      # CHNG0004475968 allow is_mw_splunk_lm_dtu for AIX
                'is_mw_splunklm_odsee',                     # CHNG0004629136 allow is_mw_splunklm_odsee for LINUX
                'is_mw_itim_compliance',                    # CHNG0004684085 allow is_mw_itim_compliance for LINUX
                'is_mw_splunklm_dtu',                       # CHNG0004740304 allow is_mw_splunklm_dtu (Aix) in eChannels
                'is_mw_splunklm_was',                       # CHNG0004948782 allow execution on Aix when in eChannels
                'is_mw_splunklm_jboss',                     # CHNG0005135477 allow execution on rhel 7
                'is_mw_splunklm_tivolitds',                 # CHNG0005141309 allow execution on rhel 7
                'is_mw_splunk_legacyeclandm',               # CHG1000172219  allow for new consolidated cookbook for eChannels
                'is_mw_jboss6_build2018',                   # CHG1000380780  allow is_mw_jboss6_build2018
                'is_mw_was8_build',                         # CHG1000421650  allow is_mw_was8_build
                'is_mw_cdunix_build2018',                   # CHG1000434823  allow is_mw_cdunix_build2018
                'is_mw_cdunix_build02',                     # CHG1002506886  allow is_mw_cdunix_build02
                'is_mw_sds_build2018',                      # CHG1000483867  allow is_mw_sds_build2018
                'is_mw_webseal_build'],                     # CHG1000524361  allow is_mw_webseal_build

  # ElasticSearch services
  'esaas-nginx' => ['bi_esaas_nginx_core'], # CHG1001612885 bi_esaas_nginx_core
  # AWS services
  'ecs' => ['cto_ahe_aws_ecs',                              # CHG1000351285  cto_ahe_aws_ecs
            'cto_demeter_ecs_dockerrhel',                   # CHG1001050512
            'cto_demeter_ecs_dockerce',                     # CHG1001050512
            'ib_eqdevops_ecs_dockerce'],                    # CHG1007292718

  'metadata-proxy' => ['cto_demeter_ecs_dockerrhel', # CHG1001050512
                       'cto_demeter_ecs_dockerce',   # CHG1001050512
                       'ib_eqdevops_ecs_dockerce'],  # CHG1007292718
  'amazon-cloudwatch-agent' => ['lib_aws_cloudwatch_agent', # CHG1000428751
                                'cto_ds_tfe_server'], # CHG1011190174

  'AmazonCloudWatchAgent' => ['lib_aws_cloudwatch_agentwindows'], # CHG1000591082

  # ! WARNING !
  # Restricted Middleware services get approval by email before adding any cookbook
  #
  # Email: PaaSMiddlewareEngineering@barclayscorp.com
  #
  # Attach email to CR. All unapproved cookbooks will be removed without notice
  #
  # ! WARNING !
  'argsd' => ['is_mw_argsclient_build'], # CHG1000344695 - service for echannels nginx and haproxy cert exchange
  'apache_2_2_redhat' => ['barcmw-pkgbase',                 # CTODEV-215 Whitelist service for middleware cookbooks
                          'barcmw-pkgbase-httpd',           # CTODEV-215 Whitelist service for middleware cookbooks
                          'is-middleware-apachehttpd-base', # CTODEV-215 Whitelist service for middleware cookbooks
                          'is-mw-apachehttpd-install',      # CTODEV-215 Whitelist service for middleware cookbooks
                          'is-mw-apachehttpd-build',        # CHNG0004854727
                          'is_mw_apachehttpd_build2018',    # CHG1000072224
                          'b-foodcritic-violator'],         # CHNG0004026256
  'daffy' => ['is_mw_daffyforlinux_build'],                 # CHNG0004899535 is_mw_daffyforlinux_build for LINUX
  'tomcat6-' => ['is-mw-tomcat-build',                      # CHNG0004910753 new service for tomcat6
                 'is_mw_tomcat_build2018'],                 # CHG1000122872 new cookbook tomcat for 2018
  'nginx' => ['is_mw_nginx_build',                          # CHNG0004730932 is_mw_nginx_build service.
              'is_mw_nginx_main',                           # CHG1001446551  is_mw_nginx_main service.
              'ib_mw_creditone_nginx'],                     # CHG1004831722  ib_mw_creditone_nginx service
  'nginx@' => ['is_mw_nginx_build',                         # CHNG0004730932 is_mw_nginx_build
               'is_mw_nginx_main'],                         # CHG1001446551  is_mw_nginx_main.
  'keepalived' => ['is_mw_nginx_build',                     # CHNG0004927272 is_mw_nginx_build
                   'is_mw_nginx_main',                      # CHG1001446551  is_mw_nginx_main.
                   'is_apaas_ecproxylb_pilot',              # CHG1000069251  is_apaas_ecproxylb_pilot
                   'is_apaas_ecproxylb_prod',               # CHG1000069251  is_apaas_ecproxylb_pilot
                   'is_mw_v4nginx_pilot1',                  # CHG1004212978  Whitelist service for V4 openshift
                   'is_apaas_v4nginx_pilot',                # CHG1004212978  Whitelist service for V4 openshift
                   'is_apaas_v4nginx_lb',                   # CHG1004212978  Whitelist service for V4 openshift
                   'bsd_devops_elk_keepalived'],            # CHG1001484559 bsd_devops_elk_keepalived
  'tomcat8@' => ['is_mw_tomcat8_build2018'],                # CHG1000454020 is_mw_tomcat8_build2018
  'jboss7@' => ['is_mw_jboss7_build02'],                    # CHG1000658214 is_mw_jboss7_build02
  'jboss@' => ['is_mw_jboss6_build2018'],                   # CHG1001416174 is_mw_jboss6_build2018
  'systemctl_enable_httpd@' => ['is-mw-apachehttpd-build',  # CHNG0003970841 is-mw-apachehttpd-build
                                'is_mw_apachehttpd_build2018'], # CHG1000072224
  'systemctl_enable_httpd@bcusapache' => ['coo_bcusdigital_httpd_app'], # CHG1002451110
  'happyd' => ['is-apaaseng-osev3-b-openshift3_enterprise', # CHG1001038930
               'is_apaasengosev3_bopenshift3enterprise_dev', # CHG1001038930
               'is_apaasengosev3_bopenshift3enterprise_pilot'], # CHG1001038930
  'apaasprereboot' => ['is-apaaseng-osev3-b-openshift3_enterprise', # CHG1003911074
                       'is_apaasengosev3_bopenshift3enterprise_dev', # CHG1003911074
                       'is_apaasengosev3_bopenshift3enterprise_pilot'], # CHG1003911074
  'httpd@' => ['is-mw-apachehttpd-build', # CHNG0003970841 is-mw-apachehttpd-build
               'is_mw_apachehttpd_build2018'], # CHG1000072224
  'httpd@bcusapache' => ['coo_bcusdigital_httpd_app'], # CHG1002451110
  'httpd' => ['is-apaaseng-osev3-b-openshift3_enterprise',  # CHNG0005007865
              'is_apaasengosev3_bopenshift3enterprise_dev', # CHNG0005007865
              'is_apaasengosev3_bopenshift3enterprise_devuat', # CHNG0005007865
              'is_apaasengosev3_bopenshift3enterprise_pilot', # CHNG0005007865
              'is-mw-apachehttpd-build',                    # CHG1001833911
              'is_mw_apachehttpd_build2018'],               # CHG1001833911
  'connectd' => ['is-mw-cd_unix-build',                     # CHNG0003997475 Connect:Direct service, is-mw-cd_unix-build
                 'is_mw_cdunix_build02',                    # CHG1002506886  allow is_mw_cdunix_build02
                 'is_mw_cdunix_build2018'],                 # CHG1000072824
  'wily' => ['is-apaaseng-osev3-b-openshift3_enterprise',   # CHNG0004084490
             'is_apaasengosev3_bopenshift3enterprise_dev',  # CHNG0004735348
             'is_apaasengosev3_bopenshift3enterprise_devuat', # CHNG0004735348
             'is_apaasengosev3_bopenshift3enterprise_pilot', # CHNG0004735348
             'is_mw_was7_build',                            # CHNG0004076577
             'is_mw_was8_build',                            # CHNG0004156962
             'is-mw-tomcat-build',                          # CHG1000061348
             'is-mw-jboss6-build',                          # CHG1000061348
             'is_mw_jboss6_build2018',                      # CHG1000442415
             'is_mw_nginx_epagent',                         # CHG1000836460
             'is_mw_v4nginx_epagent',                       # CHG1004094436
             'is_apaas_v4nginx_epagent',                    # CHG1004094436
             'is-mw-remediate-pckg',                        # CHNG0004665036
             'is_authsvcs_wily_setup',                      # CHG1003284276
             'is_mw_wily_apmia'],                           # CHG1005503224
  'wasserver' => ['is_mw_was7_build',                       # CHNG0004569997
                  'is_mw_was8_build'],
  'atomic-openshift-master-controllers' => ['is-apaaseng-osev3-b-openshift3_enterprise', # CHNG0004094413
                                            'is_apaasengosev3_bopenshift3enterprise_dev', # CHNG0004735348
                                            'is_apaasengosev3_bopenshift3enterprise_devuat', # CHNG0004735348
                                            'is_apaasengosev3_bopenshift3enterprise_pilot', # CHNG0004735348
                                            'is_apaas_openshift_cookbook'], # CHNG0004823883
  'atomic-openshift-master-api' => ['is-apaaseng-osev3-b-openshift3_enterprise', # CHNG0004094413
                                    'is_apaasengosev3_bopenshift3enterprise_dev', # CHNG0004735348
                                    'is_apaasengosev3_bopenshift3enterprise_devuat', # CHNG0004735348
                                    'is_apaasengosev3_bopenshift3enterprise_pilot', # CHNG0004735348
                                    'is_apaas_openshift_cookbook'], # CHNG0004823883
  'atomic-openshift-node' => ['is-apaaseng-osev3-b-openshift3_enterprise', # CHNG0004094413
                              'is_apaasengosev3_bopenshift3enterprise_dev', # CHNG0004735348
                              'is_apaasengosev3_bopenshift3enterprise_devuat', # CHNG0004735348
                              'is_apaasengosev3_bopenshift3enterprise_pilot', # CHNG0004735348
                              'is_apaas_openshift_cookbook'], # CHNG0004823883
  'atomic-openshift-master' => ['is_apaas_openshift_cookbook'], # CHNG0004823883
  'etcd_container' => ['is_apaas_openshift_cookbook'], # CHNG0004823883
  'openvswitch' => ['is-apaaseng-osev3-b-openshift3_enterprise', # CHNG0004094413
                    'is_apaasengosev3_bopenshift3enterprise_dev', # CHNG0004735348
                    'is_apaasengosev3_bopenshift3enterprise_devuat', # CHNG0004735348
                    'is_apaasengosev3_bopenshift3enterprise_pilot', # CHNG0004735348
                    'is_apaas_openshift_cookbook'], # CHG1000300493
  'heartbeat' => ['paas_dataware_mongo_bmongo'], # CHNG0004631818
  'auditocp' => ['is-apaaseng-osev3-b-openshift3_enterprise', # CHNG0004476306
                 'is_apaasengosev3_bopenshift3enterprise_dev', # CHNG0004735348
                 'is_apaasengosev3_bopenshift3enterprise_devuat', # CHNG0004735348
                 'is_apaasengosev3_bopenshift3enterprise_pilot'], # CHNG0004735348
  'auditocpu' => ['is-apaaseng-osev3-b-openshift3_enterprise', # CHG1000798161
                  'is_apaasengosev3_bopenshift3enterprise_dev', # CHG1000798161
                  'is_apaasengosev3_bopenshift3enterprise_devuat', # CHG1000798161
                  'is_apaasengosev3_bopenshift3enterprise_pilot'], # CHG1000798161
  'wmq-' => ['is_mw_mq_build', # CHNG0004658943
             'is_mw_mq9_echannel', # CHG1011191680
             'is_mw_mq91_build02'], # CHG1001652357
  'iib-' => ['is_mw_iib10_build'], # CHNG0004714007
  'ace-' => ['is_mw_ace_build'], # CHG1008241054
  'amq-' => ['is_mw_amq7_build02'], # CHG1001217273
  'etcd-container' => ['is_apaas_openshift_cookbook'], # CHG1001060031
  'unixagent' => ['cto_dx_teamcity_agentunix'], # CHG1001619538
  'jws5-tomcat@' => ['is_mw_jwstomcat9_build02'], # CHG1001845561
  'jws5tomcat@' => ['is_mw_jwstomcat9_build02'] # CHG1009228542
}

@etc_whitelist = {
  # common locations for additional config files
  '/etc/rsyslog.d/' => [], # CHG1001647459
  '/etc/security/limits.d/' => [], # CHG1001647459
  '/etc/systemd/system/' => [], # CHG1001647459
  '/etc/systemd/user/' => [], # CHG1001647459
  '/etc/systemd/journald.conf.d/' => [], # CHG1001647459
  '/etc/cron.allow' => [], # CHG1001647459
  '/etc/cron.daily/apache_log_archive.sh' => [],
  '/etc/cron.daily/tomcat-logs.sh' => [],
  '/etc/sysconfig/docker' => [], # CHG1001550657
  '/etc/logrotate.d/kibana' => [], # CHG1001550657
  '/etc/logrotate.d/logstash' => [], # CHG1001550657
  '/etc/logrotate.d/applogcwsservicesalpha' => [], # CHG1002990714
  '/etc/logrotate.d/applogwebalpha' => [], # CHG1002990714
  '/etc/logrotate.d/applogmobilealpha' => [], # CHG1002990714
  '/etc/sysconfig/jenkins' => [], # CHG1001550657
  '/etc/systemd/system/jenkins.service' => [], # CHG1001550657
  '/etc/init.d/jenkins' => [], # CHG1001550657
  '/etc/logrotate.d/jenkins' => [], # CHG1001550657
  '/etc/rsyslog.d/docker.conf' => [], # CHG1001550657
  '/etc/security/limits.d/94-tomcat-barcmw-limits.conf' => [],
  '/etc/sysconfig/docker-storage-setup' => [], # CHG1001550657
  '/etc/sysconfig/docker-network' => [], # CHG1001550657
  '/etc/systemd/system/docker.service.d/cgroup_driver.conf' => [], # CHG1001550657

  # cookbook specific whitelists
  '/etc/pb.settings' => ['is_iaas_unix_estatescripts'], # CHG1002171638
  '/etc/cron.d/jenkins-workspace' => ['is_cto_ife_jenkins', # CHNG0005058196
                                      'is_cto_linux_jenkins'], # CHNG0005097811
  '/etc/cron.d/esaas' => ['bsd_devops_elk_logstash'], # CHG1004935125
  '/etc/security/limits.d/93-jboss-barcmw-limits.conf' => ['is_mw_jboss6_build2018'], # CHG1000161013
  '/etc/security/limits.d/99-confluent-zookeeper.config' => ['ftc_fml_confluent_kafka', # CHG1000208703
                                                             'buk_bfa_aws_confluentkafka', # CHG1001883343
                                                             'bi_dais_kafka_wrapper'], # CHG1001225840
  '/etc/sysconfig/zookeeper' => ['ftc_fml_confluent_kafka', # CHG1000208703
                                 'buk_bfa_aws_confluentkafka', # CHG1001883343
                                 'is_mw_kafka_build02', # CHG1000967425
                                 'bi_dais_kafka_wrapper'], # CHG1001225840
  '/etc/security/limits.d/99-confluent-kafka-broker.config' => ['ftc_fml_confluent_kafka', # CHG1000208703
                                                                'buk_bfa_aws_confluentkafka', # CHG1001883343
                                                                'bi_dais_kafka_wrapper'], # CHG1001225840
  '/etc/security/limits.d/98-bpsauths-datastax-limits.conf' => ['app_bpsauths_datastax'], # CHG1000895508 - For Datastax Cassandra limits
  '/etc/sysconfig/kafka' => ['ftc_fml_confluent_kafka', # CHG1000208703
                             'buk_bfa_aws_confluentkafka', # CHG1001883343
                             'is_mw_kafka_build02', # CHG1000967425
                             'bi_dais_kafka_wrapper'], # CHG1001225840
  '/etc/nsswitch.conf' => ['gtis_chef_eicpuk_nsswitch'],
  '/etc/sysconfig/connect_standalone' => ['ftc_fml_confluent_kafka', # CHG1001114164
                                          'buk_bfa_aws_confluentkafka'], # CHG1001883343
  '/etc/rsyslog.conf' => ['is_iaas_unix_syslog',                  # CHNG0004026256
                          'barclays-base',                        # CHG1001790677
                          'b-foodcritic-violator',                # CHNG0004026256
                          'is_mw_ace_build',                      # CHG1008241054
                          'is_mw_iib10_build'],                    # CHNG0004714007
  '/etc/rsyslog.d/chef-syslogfwd.conf' => ['is_iaas_unix_syslog'], # CHNG0004026256
  '/etc/rsyslog.d/b-syslogfwd.conf' => ['is_iaas_unix_syslog'],    # CHNG0004689522
  '/etc/rsyslog.d/avc-syslogfwd.conf' => ['is_iaas_unix_syslog'], # CHG1000496536
  '/etc/rsyslog.d/consul_syslogfwd.conf' => ['cto-iaas-aws-consul'], # CHG1000678210
  '/etc/rsyslog.d/rolb-syslog.conf' => ['pcb_rolb_cwa_install'], # CHG1006965902
  '/etc/logrotate.d/rolb_logs' => ['pcb_rolb_cwa_install'], # CHG1006965902
  '/etc/rsyslog.d/atomic-openshift-node.conf' => ['is-apaaseng-osev3-b-openshift3_enterprise', # CHNG0004037516
                                                  'is_apaasengosev3_bopenshift3enterprise_dev', # CHNG0004735348
                                                  'is_apaasengosev3_bopenshift3enterprise_devuat', # CHNG0004735348
                                                  'is_apaasengosev3_bopenshift3enterprise_pilot'], # CHNG0004735348
  '/etc/rsyslog.d/atomic-openshift-master.conf' => ['is-apaaseng-osev3-b-openshift3_enterprise', # CHNG0004037516
                                                    'is_apaasengosev3_bopenshift3enterprise_dev', # CHNG0004735348
                                                    'is_apaasengosev3_bopenshift3enterprise_devuat', # CHNG0004735348
                                                    'is_apaasengosev3_bopenshift3enterprise_pilot'], # CHNG0004735348
  '/etc/rsyslog.d/oneappd.conf' => ['bi_monitoring_oneappd_eplatform'], # CHG1003611942
  '/etc/sysconfig/atomic-openshift-master' => ['is_apaas_openshift_cookbook'], # CHNG0004823883
  '/etc/sysconfig/atomic-openshift-node' => ['is_apaas_openshift_cookbook'], # CHNG0004823883
  '/etc/ecs/ecs.config' => ['cto_ahe_aws_ecs'], # CHG1000351285
  '/etc/sysconfig/openvswitch' => ['is_apaas_openshift_cookbook'], # CHNG0004823883
  '/etc/profile.d/etcdctl.sh' => ['is_apaas_openshift_cookbook'], # CHNG0004823883
  '/etc/NetworkManager/dispatcher.d/99-origin-dns.sh' => ['is_apaas_openshift_cookbook'], # CHNG0004823883
  '/etc/NetworkManager/dispatcher.d/30-ethtool' => ['mpt_ttr_onereg_ignite'], # CHG1008496186
  '/etc/logrotate.d/apaas_ose' => ['is-apaaseng-osev3-b-openshift3_enterprise', # CHNG0004197599
                                   'is_apaasengosev3_bopenshift3enterprise_dev', # CHNG0004735348
                                   'is_apaasengosev3_bopenshift3enterprise_devuat', # CHNG0004735348
                                   'is_apaasengosev3_bopenshift3enterprise_pilot'], # CHNG0004735348
  '/etc/nfsmount.conf' => ['is-apaaseng-osev3-b-openshift3_enterprise', # CHG1003345057
                           'is_apaasengosev3_bopenshift3enterprise_dev', # CHG1003345057
                           'is_apaasengosev3_bopenshift3enterprise_pilot'], # CHG1003345057
  '/etc/logrotate.d/glusterfs' => ['is_apaasengosev3_bopenshift3enterprise_pilot', # CHG1000775907
                                   'is-apaaseng-osev3-b-openshift3_enterprise'], # CHG1000775907
  '/etc/opt/mqm' => ['is_mw_mq_build', # CHNG0004145625
                     'is_mw_mq9_echannel', # CHG1011191680
                     'is_mw_mq91_build02', # CHG1001652357
                     'is_mw_mqclient_selfserve'], # CHG1000445435
  '/etc/opt/mqm/mqinst.ini' => ['is_mw_mq_build', # CHNG0004145625
                                'is_mw_mq9_echannel', # CHG1011191680
                                'is_mw_mq91_build02', # CHG1001652357
                                'is_mw_mqclient_selfserve'], # CHG1000445435
  '/etc/sysconfig/elasticsearch' => ['is_cto_aws_elasticsearch',          # CHNG0004191435
                                     'bsd_devops_elk_gru_elasticsearch',  # CHNG0004369725
                                     'bsd_devops_elk_elasticsearch',      # CHG1000494899
                                     'bi_esaas_core_elasticsearch'],      # CHG1000975645
  '/etc/sudoers' => ['is_uisec_unix_sudo', # CHNG0004208871
                     'is_mw_tomcat8_build2018', # CHG1003888716
                     'is_mw_tomcat_build2018', # CHG1003888716
                     'is_mw_apachehttpd_build2018', # CHG1003888716
                     'is_mw_jboss7_build02', # CHG1003888716
                     'is_mw_gridgain_build02', # CHG1003888716
                     'is_mw_jwstomcat9_build02'], # CHG1003888716
  '/etc/sudoers.chef' => ['is_uisec_unix_sudo', # CHNG0004208871
                          'is_mw_tomcat8_build2018', # CHG1003888716
                          'is_mw_tomcat_build2018', # CHG1003888716
                          'is_mw_apachehttpd_build2018', # CHG1003888716
                          'is_mw_jboss7_build02', # CHG1003888716
                          'is_mw_gridgain_build02', # CHG1003888716
                          'is_mw_jwstomcat9_build02'], # CHG1003888716
  '/etc/opt/quest/sudo/sudoers' => ['is_uisec_unix_sudo', # CHNG0004208871
                                    'is_mw_tomcat8_build2018', # CHG1003888716
                                    'is_mw_tomcat_build2018', # CHG1003888716
                                    'is_mw_apachehttpd_build2018', # CHG1003888716
                                    'is_mw_jboss7_build02', # CHG1003888716
                                    'is_mw_gridgain_build02', # CHG1003888716
                                    'is_mw_jwstomcat9_build02'], # CHG1003888716
  '/etc/opt/quest/sudo/sudoers.chef' => ['is_uisec_unix_sudo', # CHNG0004208871
                                         'is_mw_tomcat8_build2018', # CHG1003888716
                                         'is_mw_tomcat_build2018', # CHG1003888716
                                         'is_mw_apachehttpd_build2018', # CHG1003888716
                                         'is_mw_jboss7_build02', # CHG1003888716
                                         'is_mw_gridgain_build02', # CHG1003888716
                                         'is_mw_jwstomcat9_build02'], # CHG1003888716
  '/etc/opt/BESClient' => ['iaas_unix_ilmt_agent', # CHNG0004266773
                           'gtsm_ssm_ilmt_agent'], # CHG1014155756
  '/etc/opt/BESClient/actionsite.afxm.chef' => ['iaas_unix_ilmt_agent',  # CHNG0004266773
                                                'gtsm_ssm_ilmt_agent'],  # CHG1014155756
  '/etc/opt/BESClient/actionsite.afxm' => ['iaas_unix_ilmt_agent', # CHNG0004266773
                                           'gtsm_ssm_ilmt_agent'], # CHG1014155756
  '/etc/xinetd.d/check_mk' => ['is_mw_checkmk_agent'], # CHNG0004275345
  '/etc/systemd/system/splunk.service' => ['gis_fc2_splunk_forwarder'], # CHG1001534251
  '/etc/logrotate.d/weblogic' => ['is_mw_weblogic_build'], # CHNG0004456321
  '/etc/cron.daily/bwag_weblogic' => ['is_mw_weblogic_build'], # CHNG0004531211
  '/etc/security/limits.d/92-weblogic.conf' => ['is_mw_weblogic_build'], # CHNG0004531211
  '/etc/opt/quest/vas/users.allow' => ['is_uisec_service_watch', # CHNG0004675464
                                       'bcard_cas_apps_cron', # CHNG0004905683
                                       'bcard_cas_vec_cron', # CHNG0004921323
                                       'ib_envmgmt_radial_config', # CHG1000498991
                                       'ib_eq_galaxy_build', # CHG1000879240
                                       'ib_eq_pumajboss_build', # CHG1001027818
                                       'bcard_cas_obs_cron', # CHG1000568241
                                       'b-vas_manage', # CHG1000909001
                                       'gtis_vm_unix_tool', # CHG1002874225
                                       'buk_etp_vas_wrapper'], # CHG1014427141
  '/etc/opt/quest/vas/users.deny' => ['b-vas_manage'], # CHG1000909001
  '/etc/opt/quest/vas/vas.conf' => ['b-vas_manage'], # CHG1000909001
  '/etc/barclays.server.info' => ['b-vas_manage'], # CHG1000909001
  '/opt/support/etc/barclays-release' => ['b-vas_manage'], # CHG1000909001
  '/opt/tsg/std.build.info' => ['b-vas_manage'], # CHG1000909001
  '/etc/puppet/std.build.info' => ['b-vas_manage'], # CHG1000909001
  '/etc/pam.d/password-auth' => ['b-vas_manage'], # CHG1000909001
  '/etc/pam.d/password-auth-ac' => ['b-vas_manage'], # CHG1000909001
  '/etc/pam.d/powerbroker' => ['b-vas_manage'], # CHG1000909001
  '/etc/pam.d/runuser' => ['b-vas_manage'], # CHG1000909001
  '/etc/pam.d/runuser-l' => ['b-vas_manage'], # CHG1000909001
  '/etc/pam.d/smartcard-auth' => ['b-vas_manage'], # CHG1000909001
  '/etc/pam.d/smartcard-auth-ac' => ['b-vas_manage'], # CHG1000909001
  '/etc/pam.d/system-auth' => ['b-vas_manage'], # CHG1000909001
  '/etc/pam.d/system-auth-ac' => ['b-vas_manage'], # CHG1000909001
  '/etc/pam.d/vmtoolsd' => ['b-vas_manage'], # CHG1000909001
  '/etc/pam.d/cvs' => ['coo_bcdcm_cvs_app'], # CHG1002585008
  '/etc/xinetd.d/cvs' => ['coo_bcdcm_cvs_app'], # CHG1002585008
  '/etc/sysconfig/pm2' => ['bci_devops_core_nodejs'], # CHNG0004620040
  '/etc/systemd/system/pm2.service' => ['bci_devops_core_nodejs'], # CHNG0004620040
  '/etc/init.d/wmq-' => ['is_mw_mq_build'], # CHNG0004658943
  '/etc/systemd/system/wmq-' => ['is_mw_mq_build', # CHNG0004658943
                                 'is_mw_mq9_echannel', # CHG1011191680
                                 'is_mw_mq91_build02'], # CHG1001652357
  '/etc/pki/tls/certs/Live_Root_Certs.pem' => ['is_iaas_unix_ssl'], # CHNG0004723850
  '/etc/pki/ca-trust/source/anchors/Live_Root_Certs.pem' => ['is_iaas_unix_ssl'], # CHNG0004723850
  '/etc/pki/ca-trust/source/anchors/' => ['is_iaas_unix_ssl'], # CHG1000960821
  '/etc/rsyslog.d/rate-limit.conf' => ['is-apaaseng-osev3-b-openshift3_enterprise', # CHNG0004841172
                                       'is_apaasengosev3_bopenshift3enterprise_dev', # CHNG0004841172
                                       'is_apaasengosev3_bopenshift3enterprise_devuat', # CHNG0004841172
                                       'is_apaasengosev3_bopenshift3enterprise_pilot'], # CHNG0004841172
  '/etc/init.d/appdynamics-machine-agent' => ['bci_core_appd_agent', # CHNG0004980736
                                              'buk_transformation_appdynamics_orchestration', # CHG1001119359
                                              'bi_rtbmonitoring_appdynamics_agent'], # CHG1001516744
  '/etc/sysconfig/appdynamics-machine-agent' => ['bci_core_appd_agent', # CHNG0004980736
                                                 'buk_transformation_appdynamics_orchestration', # CHG1001119359
                                                 'bi_rtbmonitoring_appdynamics_agent'], # CHG1001516744
  '/etc/pki/ca-trust/source/anchors/openshift-ca.crt' => ['is_apaas_openshift_cookbook'], # CHNG0005058750
  '/etc/kdump.conf' => ['gtis_unix_kdump_client'], # CHNG0005255084
  '/etc/logrotate.d/resilient-circuits' => ['gis_fc2_unix_resilient'], # CHG1000240065
  '/etc/pki/tls/certs/' => ['gtis_hosting_cloud_ca'], # CHG1000256228
  '/etc/pki/tls/private/' => ['gtis_hosting_cloud_ca'], # CHG1000256228
  '/etc/pam.d/mongodb' => ['gtis_dataware_mongodb_automation', # CHG1000370342
                           'gtis_dataware_mongodb_onpremautomation'], # CHG1001836124
  '/etc/logrotate.d/amazon-cloudwatch-agent' => ['lib_aws_cloudwatch_agent'], # CHG1000428751
  '/etc/cron.hourly/amazon-cloudwatch-agent' => ['lib_aws_cloudwatch_agent'], # CHG1000428751
  '/etc/security/limits.d/40-swift-limits.conf' => ['gtis_swift_sag_build'], # CHG1000505284
  '/etc/opt/secrets_backup' => ['gtis_swift_sag_build'], # CHG1000612714
  '/etc/opt/swnet' => ['gtis_swift_sag_build'], # CHG1000612714
  '/etc/rsyslog.d/kamailio.conf' => ['cto_arch_kama_cookbook'], # CHG1000672597
  '/etc/cron.d/cacti' => ['is_gtis_storage_cacti'], # CHG1000766208
  '/etc/at.allow' => ['gtis_swift_fac_build'], # CHG1000798688
  '/etc/fstab' => ['ib_dev_ccar_app'], # CHG1000800610
  '/etc/udev/rules.d/50-aerospike.rules' => ['ftc_fml_platform_aerospike', # CHG1000835344
                                             'ftc_platform_aerospike_base'], # CHG1008103471
  '/etc/my.cnf.d/server.cnf' => ['is_gtis_storage_cacti'], # CHG1000806640
  '/etc/resolv.conf' => ['ib_eq_galaxy_build', # CHG1000879240
                         'ib_eq_pumajboss_build', # CHG1001027818
                         'eq_mo_mocha_build', # CHG1002458787
                         'aett_bats_core_aws'], # CHG1004814598
  '/etc/profile.d/jdk.sh' => ['b_iac_cc_java'], # CHG1000873307
  '/etc/auto.' => ['ftc_fml_platform_aerospike', # CHG1001095695
                   'ftc_platform_aerospike_base'], # CHG1008103471
  '/etc/auto.master.d/' => ['ftc_fml_platform_aerospike', # CHG1001095695
                            'ftc_platform_aerospike_base'], # CHG1008103471
  '/etc/my.cnf' => ['gtis_macos_jamfpro_inf', # CHG1001240456
                    'gtis_macos_jamfpro_infrhel8'], # CHG1016322082
  '/etc/sysconfig/memcached' => ['gtis_macos_jamfpro_inf', # CHG1001240456
                                 'gtis_macos_jamfpro_infrhel8'], # CHG1016322082
  '/etc/logrotate.d/nginx' => ['bi_esaas_nginx_core', # CHG1001761838
                               'corporate_digital_nginx_srv'], # CHG1010935586
  '/etc/pki/ca-trust/source/anchors/TestGlobalInfrastructure7.crt' => ['coo_ie_certs_base'], # CHG1002451859
  '/etc/pki/ca-trust/source/anchors/TestGlobalInfrastructureRootCA7.cer' => ['ib_cspt_taurus_infra'], # CHG1009265185
  '/etc/pki/ca-trust/source/anchors/TaurusApiAuthProd.cer' => ['ib_cspt_taurus_infra'], # CHG1009565761
  '/etc/sysconfig/vault' => ['cibd_tech_vault_cfn', # CHG1004688145
                             'cibd_tech_devops_vault'], # CHG1004688145
  '/etc/sysconfig/consul' => ['cibd_tech_devops_consul'], # CHG1004688145
  '/usr/lib/systemd/system/elastic-agent.service' => ['gtis_esaas_elasticagent_oracle'], # CHG1015034829
  # barclays-base locked files
  '/etc/chef/client.pem' => ['barclays-base'], # CHG1001790677
  '/etc/syslog.conf' => ['barclays-base'], # CHG1001790677
  '/opt/support/etc/cron.daily/chef-client' => ['barclays-base'], # CHG1001790677
  '/var/spool/cron/crontabs/root' => ['barclays-base'], # CHG1001790677
  '/root/.ssh/authorized_keys' => ['barclays-base'], # CHG1001790677
  '/root/.ssh2/authorization' => ['barclays-base'], # CHG1001790677
  '/root/.ssh/identification' => ['barclays-base'], # CHG1001790677
  '/etc/opt/rh/jws5/sysconfig/tomcat@' => ['is_mw_jwstomcat9_build02'], # CHG1001845561
  '/etc/profile.d/init_env_vars.sh' => ['dx_citools_agent_rhel', # CHG1002264742
                                        'rft_automation_axis_unix', # CHG1008872648
                                        'dx_citools_agent_rhel8'], # CHG1011515739
  '/etc/cron.daily/oracle_os_comp_check.sh' => ['gtis_database_oracle_scd'], # CHG1002507218
  '/etc/alternatives/jre/lib/ext/libLunaAPI.so' => ['gtis_macos_jamfpro_inf'], # CHG1002617331
  '/etc/alternatives/jre/lib/ext/LunaProvider.jar' => ['gtis_macos_jamfpro_inf'], # CHG1002617331
  '/etc/alternatives/jre/lib/ext/jcprov.jar' => ['gtis_macos_jamfpro_inf'], # CHG1002617331
  '/etc/alternatives/jre/lib/ext/libjcprov.so' => ['gtis_macos_jamfpro_inf'], # CHG1002617331
  '/etc/alternatives/jre/lib/security/java.security' => ['gtis_macos_jamfpro_inf'], # CHG1002600865
  '/etc/ntp.conf' => ['pcb_swift_agi_ntp'], # CHG1003036322
  '/etc/sysconfig/ntpd' => ['pcb_swift_agi_ntp', # CHG1003036322
                            'pcb_swift_agi_chrony'], # CCHG1004907741
  '/usr/lib/systemd/system/ccib-appd-machine-agent.service' => ['bci_ccib_wfm_appdynamics'], # CHG1003502799
  '/usr/lib/systemd/system/ccib-avaya-realtime-prod-ccup1.service' => ['bci_ccib_wfm_avayaproducer'], # CHG1003281195
  '/usr/lib/systemd/system/ccib-avaya-realtime-prod-ccup2-1.service' => ['bci_ccib_wfm_avayaproducer'], # CHG1003281195
  '/usr/lib/systemd/system/ccib-avaya-realtime-prod-ccup2-2.service' => ['bci_ccib_wfm_avayaproducer'], # CHG1003281195
  '/usr/lib/systemd/system/ccib-avaya-realtime-prod-ccup2.service' => ['bci_ccib_wfm_avayaproducer'], # CHG1003281195
  '/usr/lib/systemd/system/ccib-rt-splitter-prod-ccup1-primary.service' => ['bci_ccib_wfm_avayaproducer'], # CHG1003281195
  '/usr/lib/systemd/system/ccib-rt-splitter-prod-ccup1-secondary.service' => ['bci_ccib_wfm_avayaproducer'], # CHG1003281195
  '/usr/lib/systemd/system/ccib-rt-splitter-prod-ccup2-1-primary.service' => ['bci_ccib_wfm_avayaproducer'], # CHG1003281195
  '/usr/lib/systemd/system/ccib-rt-splitter-prod-ccup2-1-secondary.service' => ['bci_ccib_wfm_avayaproducer'], # CHG1003281195
  '/usr/lib/systemd/system/ccib-rt-splitter-prod-ccup2-primary.service' => ['bci_ccib_wfm_avayaproducer'], # CHG1003281195
  '/usr/lib/systemd/system/ccib-rt-splitter-prod-ccup2-secondary.service' => ['bci_ccib_wfm_avayaproducer'], # CHG1003281195
  '/usr/lib/systemd/system/mysqld.service' => ['ib_rft_unix_radial', # CHG1005061474
                                               'ib_rft_unix_bdh'], # CHG1007345746
  '/usr/lib/systemd/system/datacopier.service' => ['ib_rft_unix_radial', # CHG1007345746
                                                   'ib_rft_unix_bdh'], # CHG1007345746
  '/etc/rsyslog.d/eqvault.conf' => ['ib_eqdevops_apps_base'], # CHG1003490104
  '/etc/mail/sendmail.cf' => ['tpe_mpt_mptrader_aws'], # CHG1003650730
  '/etc/mail/submit.cf' => ['tpe_mpt_mptrader_aws'], # CHG1004575012
  '/etc/rsyslog.d/dockerd.conf' => ['ib_eqdevops_docker_base'], # CHG1003899217
  '/usr/lib/systemd/system/docker.service' => ['ib_eqdevops_docker_base'], # CHG1004645074
  '/etc/rsyslog.d/cso_splunk_logsec.conf' => ['cso_sets_logsec_splunk'], # CHG1004049096
  '/etc/postfix/main.cf' => ['ib_rft_unix_radial', # CHG1004503389
                             'ib_rft_unix_bdh'], # CHG1007345746
  '/etc/chrony.conf' => ['pcb_swift_agi_chrony'], # CHG1004776400
  '/etc/sysconfig/chronyd' => ['pcb_swift_agi_chrony'], # CHG1004776400
  '/etc/rsyslog.d/53-logging.conf' => ['tc2_dsp_aws_datarobot'], # CHG1004989402
  '/etc/rsyslog.d/51-datarobot.conf' => ['tc2_dsp_aws_datarobot'], # CHG1004989402
  '/etc/rsyslog.d/52-server.conf' => ['tc2_dsp_aws_datarobot'], # CHG1004989402
  '/etc/opt/CARKaim/vault/vault.ini' => ['ib_eqfin_segway_icp', # CHG1008840776
                                         'cso_iam_cyberark_unix', # CHG1009709272
                                         'coo_ie_bcus_cyberarkeicp'], # CHG1011690162
  '/usr/lib/systemd/system/docker.socket' => ['ib_smad_server_base'], # CHG1009114122
  '/etc/systemd/system/gtisobs.service' => ['gtis_obs_core_linux'], # CHG1010854557
  '/etc/opt/microsoft/mdatp/managed/mdatp_managed.json' => ['cso_sets_mde_unix'] # CHG1015086631
}

@etc_blacklist = [
  ############ Directories ############
  '/etc/BClocal/',
  '/etc/ConsoleKit/',
  '/etc/NetworkManager/',
  '/etc/X11/',
  '/etc/abrt/',
  '/etc/acpi/',
  '/etc/alsa/',
  '/etc/alternatives/',
  '/etc/ant.d/',
  '/etc/audisp/',
  '/etc/audit/',
  '/etc/avahi/',
  '/etc/bash_completion.d/',
  '/etc/blkid/',
  '/etc/brltty/',
  '/etc/certmonger/',
  '/etc/chef/',
  '/etc/chkconfig.d/',
  '/etc/cron.d/',
  '/etc/cron.daily/',
  '/etc/cron.hourly/',
  '/etc/cron.monthly/',
  '/etc/cron.weekly/',
  '/etc/cups/',
  '/etc/dbus-1/',
  # '/etc/default/', -- allowed
  '/etc/depmod.d/',
  '/etc/dhcp/',
  '/etc/dracut.conf.d/',
  '/etc/edac/',
  '/etc/event.d/',
  '/etc/facter/',
  '/etc/fonts/',
  '/etc/foomatic/',
  '/etc/gconf/',
  '/etc/gcrypt/',
  '/etc/ghostscript/',
  '/etc/gnupg/',
  '/etc/gtk-2.0/',
  '/etc/hal/',
  '/etc/hp/',
  # '/etc/init.d/', -- allowed
  # '/etc/init/', -- allowed
  '/etc/ipa/',
  '/etc/iproute2/',
  '/etc/ipsec.d/',
  '/etc/java/',
  '/etc/jvm-commmon/',
  '/etc/jvm/',
  '/etc/kdump-adv-conf/',
  '/etc/ktune.d/',
  '/etc/latrace.d/',
  '/etc/ld.so.conf.d/',
  '/etc/libreport/',
  '/etc/libvirt/',
  '/etc/logrotate.d/',
  '/etc/logwatch/',
  '/etc/lsb-release.d/',
  '/etc/lvm/',
  '/etc/mail/',
  '/etc/makedev.d/',
  '/etc/maven/',
  '/etc/mcelog/',
  '/etc/mercurial/',
  '/etc/modprobe.d/',
  '/etc/multipath/',
  '/etc/ntp/',
  '/etc/oddjob/',
  '/etc/oddjobd.conf.d/',
  '/etc/openldap/',
  '/etc/opt/',
  '/etc/pam.d/',
  '/etc/pango/',
  '/etc/pcmcia/',
  '/etc/pkcs11/',
  '/etc/pki/',
  '/etc/plymouth/',
  '/etc/pm/',
  '/etc/polkit-1/',
  '/etc/popt.d/',
  '/etc/portreserve/',
  '/etc/postfix/',
  '/etc/ppp/',
  '/etc/prelink.conf.d/',
  '/etc/profile.d/',
  '/etc/pulse/',
  '/etc/puppet/',
  '/etc/rc.d/',
  '/etc/rc0.d/',
  '/etc/rc1.d/',
  '/etc/rc2.d/',
  '/etc/rc3.d/',
  '/etc/rc4.d/',
  '/etc/rc5.d/',
  '/etc/rc6.d/',
  '/etc/reader.conf.d/',
  '/etc/redhat-lsb/',
  '/etc/request-key.d/',
  '/etc/rpm/',
  '/etc/rpmdevtools/',
  '/etc/rpmlint/',
  '/etc/rsc/',
  '/etc/rsyslog.d/',
  '/etc/rwtab.d/',
  '/etc/samba/',
  '/etc/sane.d/',
  '/etc/sasl2/',
  '/etc/scl/',
  '/etc/security/',
  '/etc/selinux/',
  '/etc/setuptool.d/',
  '/etc/sgml/',
  '/etc/skel/',
  '/etc/smrsh/',
  '/etc/snmp/',
  '/etc/ssh/',
  '/etc/ssl/',
  '/etc/sssd/',
  '/etc/stap-server/',
  '/etc/statetab.d/',
  '/etc/subversion/',
  '/etc/sudoers.d/',
  '/etc/sysconfig/',
  '/etc/systemtap/',
  '/etc/terminfo/',
  '/etc/texmf/',
  '/etc/tune-profiles/',
  '/etc/udev/',
  '/etc/xdg/',
  '/etc/xinetd.d/',
  '/etc/xml/',
  '/etc/yum.repos.d/',
  '/etc/yum/',
  ############ Files ############
  '/etc/.bclocation',
  '/etc/.pwd.lock',
  '/etc/BCrelease',
  '/etc/DIR_COLORS',
  '/etc/DIR_COLORS.256color',
  '/etc/DIR_COLORS.lightbgcolor',
  '/etc/Trolltech.conf',
  '/etc/adjtime',
  '/etc/aliases',
  '/etc/aliases.db',
  '/etc/anacrontab',
  '/etc/ant.conf',
  '/etc/asound.conf',
  '/etc/at.allow',
  '/etc/at.deny',
  '/etc/auto.master',
  '/etc/auto.misc',
  '/etc/auto.net',
  '/etc/auto.smb',
  '/etc/auto.users',
  '/etc/auto_master',
  '/etc/autofs_ldap_auth.conf',
  '/etc/barclays.server.info',
  '/etc/bashrc',
  '/etc/bc.yum',
  '/etc/bc.yum.bak',
  '/etc/bc_staticroutes',
  '/etc/brltty.conf',
  '/etc/cas.conf',
  '/etc/cgconfig.conf',
  '/etc/cgrules.conf',
  '/etc/cgsnapshot_blacklist.conf',
  '/etc/cron.allow',
  '/etc/cron.deny',
  '/etc/crontab',
  '/etc/crypttab',
  '/etc/csh.cshrc',
  '/etc/csh.login',
  '/etc/dracut.conf',
  '/etc/drirc',
  '/etc/enscript.cfg',
  '/etc/environment',
  '/etc/ethers',
  '/etc/exports',
  '/etc/favicon.png',
  '/etc/filesystems',
  '/etc/fprintd.conf',
  '/etc/fstab',
  '/etc/ftpusers',
  '/etc/gai.conf',
  '/etc/group',
  '/etc/group-',
  '/etc/grub.conf',
  '/etc/gshadow',
  '/etc/gshadow-',
  '/etc/gssapi_mech.conf',
  '/etc/host.conf',
  '/etc/hosts',
  '/etc/hosts.allow',
  '/etc/hosts.bak',
  '/etc/hosts.deny',
  '/etc/idmapd.conf',
  '/etc/inittab',
  '/etc/inputrc',
  '/etc/ipsec.conf',
  '/etc/ipsec.secrets',
  '/etc/issue',
  '/etc/issue.net',
  '/etc/kdump.conf',
  '/etc/krb5.conf', # Reserverd for Infra Services. To avoid conflict restrict App. cookbook from managing this file
  '/etc/kshrc',
  '/etc/latrace.conf',
  '/etc/ld.so.cache',
  '/etc/ld.so.conf',
  '/etc/libaudit.conf',
  '/etc/libuser.conf',
  '/etc/localtime',
  '/etc/login.defs',
  '/etc/logrotate.conf',
  '/etc/lsb-release',
  '/etc/ltrace.conf',
  '/etc/magic',
  '/etc/mail.rc',
  '/etc/mailcap',
  '/etc/man.config',
  '/etc/mime.types',
  '/etc/mke2fs.conf',
  '/etc/mkshrc',
  '/etc/motd',
  '/etc/motd.new',
  '/etc/mtab',
  '/etc/mtools.conf',
  '/etc/multipath.conf',
  '/etc/my.cnf',
  '/etc/nanorc',
  '/etc/ndd.conf',
  '/etc/netconfig',
  '/etc/networks',
  '/etc/nfsmount.conf',
  '/etc/nscd.conf',
  '/etc/nslcd.conf',
  '/etc/nsswitch.conf',
  '/etc/ntp.conf',
  '/etc/numad.conf',
  '/etc/oddjobd.conf',
  '/etc/openct.conf',
  '/etc/pam_ldap.conf',
  '/etc/passwd',
  '/etc/passwd-',
  '/etc/pb.key',
  '/etc/pb.settings',
  '/etc/pbm2ppa.conf',
  '/etc/pinforc',
  '/etc/pm-utils-hd-apm-restore.conf',
  '/etc/pnm2ppa.conf',
  '/etc/prelink.cache',
  '/etc/prelink.conf',
  '/etc/printcap',
  '/etc/profile',
  '/etc/protocols',
  '/etc/quotagrpadmins',
  '/etc/quotatab',
  '/etc/rc',
  '/etc/rc.local',
  '/etc/rc.sysinit',
  '/etc/rc0.d',
  '/etc/rc1.d',
  '/etc/rc2.d',
  '/etc/rc3.d',
  '/etc/rc4.d',
  '/etc/rc5.d',
  '/etc/rc6.d',
  '/etc/readahead.conf',
  '/etc/redhat-release',
  '/etc/request-key.conf',
  '/etc/resolv.conf',
  '/etc/rpc',
  '/etc/rsyslog.conf',
  '/etc/rwtab',
  '/etc/screenrc',
  '/etc/securetty',
  '/etc/sensors3.conf',
  '/etc/services',
  '/etc/sestatus.conf',
  '/etc/shadow',
  '/etc/shadow-',
  '/etc/shells',
  '/etc/smartd.conf',
  '/etc/sos.conf',
  '/etc/statetab',
  '/etc/sudo-ldap.conf',
  '/etc/sudo.conf',
  '/etc/sudoers',
  '/etc/sysctl.conf',
  '/etc/syslog.conf',
  '/etc/system-release',
  '/etc/system-release-cpe',
  '/etc/tcsd.conf',
  '/etc/tuned.conf',
  '/etc/updatedb.conf',
  '/etc/vimrc',
  '/etc/virc',
  '/etc/warnquota.conf',
  '/etc/wgetrc',
  '/etc/xinetd.conf',
  '/etc/yp.conf',
  '/etc/yum.conf',
  '/etc/zlogin',
  '/etc/zlogout',
  '/etc/zprofile',
  '/etc/zshenv',
  '/etc/zshrc',
  '/usr/lib/systemd/',
  '/var/spool/cron/crontabs/root',
  '/root/.ssh/',
  '/root/.ssh2/'
]

@cmd_whitelist = {
  '    lvcreate -L 3G -n oselog root_vg
    mkfs.ext4 /dev/mapper/root_vg-oselog
    mkdir /var/log/openshift
    chmod 777 /var/log/openshift
    echo "/dev/mapper/root_vg-oselog /var/log/openshift ext4 defaults,discard,nodev,nosuid 1 2" >> /etc/fstab
    mount -a
    restorecon /var/log/openshift/
' => ['is-apaaseng-osev3-b-openshift3_enterprise', # CHNG0004129770
      'is_apaasengosev3_bopenshift3enterprise_dev', # CHNG0004735348
      'is_apaasengosev3_bopenshift3enterprise_devuat', # CHNG0004735348
      'is_apaasengosev3_bopenshift3enterprise_pilot'], # CHNG0004735348
  'pm2 kill' => ['bci_devops_core_nodejs'], # CHNG0004620040
  'sudo /opt/chef/scripts/chef-client-wrapper > /dev/null 2>&1' => [], # CHG1000170695
  '      yum install --downloadonly --downloaddir=/tmp/ ' => ['cft_credit_java_remediation'], # CHG1000214099
  '      yum install -y --downloadonly --downloaddir=/tmp/ ' => ['cft_wps_bcl_javainstall'], # CHG1000240791
  'crontab -l | grep -q "/apps/galaxy/cfg/check/CoreWatch.pl" || (crontab  -l; echo "0 2 * * 6 /apps/galaxy/cfg/check/CoreWatch.pl" ) | crontab - ' => ['is_cto_awsbuild_rhel'], # CHG1000417605
  '/usr/bin/crontab -l | /usr/bin/grep -v "/apps/galaxy/cfg/check/CoreWatch.pl" | /usr/bin/crontab - ' => ['is_cto_awsbuild_rhel'], # CHG1000417605
  '/usr/bin/crontab -l | grep -q "/apps/galaxy/cfg/check/CoreWatch.pl" || (/usr/bin/crontab  -l; echo "0 2 * * 6 /apps/galaxy/cfg/check/CoreWatch.pl" ) | /usr/bin/crontab - ' => ['is_cto_awsbuild_rhel'], # CHG1000417605
  'yumdownloader  -  && rpm -ivh  ' => ['ib_envmgmt_radial_java', # CHG1000498991
                                        'ib_rft_unix_generic'], # CHG1002099443
  'parted ' => ['ib_rft_unix_bdh'], # CHG1011679332
  'mount' => ['ib_rft_unix_bdh'], # CHG1012679275
  'mkfs.xfs' => ['ib_rft_unix_bdh'], # CHG1012679275
  '/usr/bin/rpm -i' => ['is_mw_mqclient_selfserve'], # CHG1016813387
  'umount "${TARGET_DEVICE}"' => ['ftc_fml_platform_aerospike', # CHG1001095695
                                  'ftc_platform_aerospike_base'], # CHG1008103471
  'set-netfirewallprofile -profile domain,public,private -enabled true' => ['b_win_netseg_tetrationagent'], # CHG1006178638
}

@platform_cookbook_whitelist = [
  'is_iaas_rhel_base', # CHG1004508997
  'b_win_all_deploymenthelper', # CHNG0005063136
  'b_win_all_scom', # CHNG0004750086
  'b_win_server_access', # CHNG0004478032
  'b_win_all_platformrevision', # CHNG0004219959
  'b_win_all_mcafee_ens_threatprevention', # CHNG0004275099
  'is_iaas_unix_ntp', # CHNG0004510260
  'gis_secdevops_os_core', # CHNG0004349296
  'gtis_oracle_inventory_collector', # eicp-uk build
  'is_iaas_flo_build', # FLO build for Equities CHNG0004595948
  'is_iaas_batman_build', # Batman build for Equities CHNG0004595948
  'is_iaas_blackbird_build', # Blackbird build for Equities CHNG0004595948
  'is_iaas_compass_build', # Compass build for Equities CHNG0004595948
  'ib_ibt_aett_build', # AETT build CHNG0004707806
  'ib_eq_legacy_build', # EQ Legacy application build cookbook CHNG0004809187
  'iaas_unix_sysgisva_local', # CHNG0004680342
  'iaas_unix_syssshukm_local', # CHNG0004695730
  'ib_eq_flowdev_eqflowvolemea', # FLOW build for EMAE CHNG0004872619
  'is_iaas_nightwing_build', # Nightwing build for Equities CHNG0004881535
  'is_iaas_unix_fixhptools', # CHNG0004899150
  'ib_eq_cbts_build', # CHNG0004943683
  'ib_eq_puma_build', # CHNG0004973278
  'ib_eq_legacyapps_emea', # EQ Legacy EMEA build cookbook CHNG0005028278
  'is_uisec_service_watch', # Service Discovery AIX user creation CHNG0005048443
  'b_win_all_sccmagent', # CHNG0005049515
  'b_win_all_sep14', # CHNG0005132802
  'ib_eq_tiger_build', # CHNG0005156255
  'b_win_all_sep12', # CHNG0005202347
  'b_win_all_meltdownfixprereq', # CHG1000014912
  'b_win_all_rapidfixes', # CHG1000122365
  'b_win_dmz_servicenowdiscovery', # CHG1000119250
  'is_iaas_unix_audit', # CHG1000296350
  'is_iaas_unix_network', # CHG1000305469
  'b_iac_cc_lvm', # CHG1000448720
  'rft_basis_sap_nw', # CHG1000498094
  'b_unix_base_core', # CHG1000606795
  'b_unix_base_common', # CHG1000606795
  'b_unix_base_echan', # CHG1000606795
  'b_unix_base_chef', # CHG1000606795
  'b_unix_base_eicp', # CHG1002122480
  'b_unix_base_eicpuk', # CHG1004331773
  'barclays-base', # CHG1001790677
  'b_win_all_hardenserver', # CHG1000616551
  'is_uisec_unix_hardening', # CHG1000704885
  'b_win_all_upp_integration', # CHG1000824501
  'iaas_storage_nfs_mount', # CHG1000854962
  'chef-server-config', # CHG1000928256
  'b_win_all_rdsrole', # CHG1000943563
  'b-users_manage', # CHG1001223921
  'b-omnibus_updater', # CHG1001504708
  'gtis_unix_yum_http', # CHG1001522430
  'b_win_all_device42access', # CHG1001731994
  'is_iaas_unix_remediation', # CHG1002886347
  'b_win_all_breakglassgroupremove', # CHG1003359761
  'ib_rft_win_hpc', # CHG1003422614
  'is_iaas_pacemaker_setuppcs', # CHG1003568043
  'is_mw_tomcat8_build2018', # CHG1003888716
  'is_mw_tomcat_build2018', # CHG1003888716
  'is_mw_apachehttpd_build2018', # CHG1003888716
  'is_mw_jboss7_build02', # CHG1003888716
  'is_mw_gridgain_build02', # CHG1003888716
  'is_mw_jwstomcat9_build02', # CHG1003888716
  'b_win_all_wsus', # CHG1004025285
  'is_iaas_unix_krb5', # CHG1003950965
  'b-auth', # CHG1004169308
  'b-build-compliance', # CHG1004169308
  'b-echan-specific', # CHG1004169308
  'b-identification', # CHG1004169308
  'b-line', # CHG1004169308
  'b-monitoring', # CHG1004169308
  'b-rhel7-build', # CHG1004169308
  'b-rhel7-latest', # CHG1004169308
  'b-vas_manage', # CHG1004169308
  'b_all_production_blocker', # CHG1004169308
  'barclays-incident-fixes', # CHG1004169308
  'barclays-security-audit-aix', # CHG1004169308
  'barclays-security-audit-rhel', # CHG1004169308
  'chef-client', # CHG1004169308
  'chef_handler', # CHG1004169308
  'cron', # CHG1004169308
  'gtis_unix_usb_disable', # CHG1004169308
  'iaas_unix_ilmt_agent', # CHG1004169308
  'iaas_unix_sysipcpr_local', # CHG1004169308
  'insv_eme_tanium_client', # CHG1004169308
  'iptables', # CHG1004169308
  'is_iaas_unix_ec_powerbroker', # CHG1004169308
  'is_iaas_unix_estatescripts', # CHG1004169308
  'is_iaas_unix_ssl', # CHG1004169308
  'is_iaas_unix_syslog', # CHG1004169308
  'is_uisec_unix_sudo', # CHG1004169308
  'line', # CHG1004169308
  'logrotate', # CHG1004169308
  'ohai', # CHG1004169308
  'paas_mw_corebase_prod', # CHG1004169308
  'selinux', # CHG1004169308
  'unix-audit-remediation', # CHG1004169308
  'yum', # CHG1004169308
  'is_iaas_aix_remediation', # CHG1004286378
  'is_iaas_aix_audit', # CHG1004286378
  'gtis_iac_aws_efsmount', # CHG1004669761
  'chef-client', # CHG1005714394
  'unix-audit-remediation', # CHG1006235374
  'is_iaas_rhel_cipehardenbuild', # CHG1006235374
  'is_iaas_chef_16', # CHG1006235374
  'cron', # CHG1006235374
  'is_iaas_unix_powerbroker', # CHG1006952451
  'is_iaas_unix_powerbrokercl', # CHG1017244920
  'is_iaas_unix_estatescripts', # CHG1006952451
  'is_iaas_build_compliance', # CHG1006952451
  'api_servishmesh_anjuna_awsenclave', # CHG1007738647
  'b_win_chefclientupdater', # CHG1007750739
  'is_iaas_rhel_ipusetup', # CHG1008649786
  'is_iaas_rhel_ipufstab', # CHG1012418924
  'cso_sets_mdca_docker', # CHG1009709272
  'is_iaas_aix_base', # CHG1010065051
  'b_win_all_security_compliance', # CHG1011786282
  'b_win_all_secbaseline', # CHG1011786282
  'gtis_chef_client_config', # CHG1013346944
  'ib_hpc_dsengine_azwin', # CHG1014154347
]

# BARC015 Whitelist for adding cookbook to use the Chef cron resource with root user account
@cron_root_whitelist = [
  'cso_sets_mde_unix', # CHG1021330268
]

# BARC016 Whitelist for adding cookbook to use rpm command
@rpm_cookbook_whitelist = [
  'is_mw_mqclient_selfserve' # CHG1016931009
]

# BARC007 whitelist for adding the selinux context to application directories 3 CHG1010935341
@selinux_cookbook_whitelist = [
  'rft_basis_sap_netweaver', # CHG1010935341
  'rft_basis_sap_hana', # CHG1010935341
  'tc25_rft_flowfin_configureignitecluster', # CHG1011089224
  'gtis_chef_infrastructure_pipelineproxy', #CHG1001647459
  'rft_basis_sap_iq' #CHG1019672246
]

# BARC001-2 whitelist for local users/groups manipulations - Added whitelist CHG1001597938
@local_access_cookbook_whitelist = ['ib_rft_win_generic', # CHG1001597938
                                    'gtis_vm_unix_tool', # CHG1002874225
                                    'is_mw_mq91_build02', # CHG1003785694
                                    'is_mw_mq9_echannel', # CHG1011191680
                                    'buk_etp_sql_deploy', # CHG1005868286
                                    'api_servishmesh_anjuna_awsenclave', # CHG1007715585
                                    'gtis_apphosting_eks_unmanaged08118', # CHG1006546166
                                    'is_mw_udmagentwin_build02', # CHG1018993064
                                    'mpt_cma_win_generic'] # CHG1012537141

# BARC006 whitelist for reboot resource and commands - Added whitelist CHG1001320435
@reboot_cookbook_whitelist = [
  'buk_etp_pubreadsrvc_install', # CHG1005525136
  'rft_basis_sap_hana', # CHG1001320435
  'rft_basis_sap_iq' #CHG1019672246
]

@tag_whitelist = {
  'ib_qa_common_windows' => %w[qa-infra-node qa-infra-windows-node], # CHG1008598145
  'ib_qa_common_linux' => %w[qa-infra-node qa-infra-linux-node], # CHG1008598145
  'is-apaaseng-osev3-b-openshift3_enterprise' => ['ocp-node', 'ocp-auth'], # CHG1002832748
  'is_apaasengosev3_bopenshift3enterprise_dev' => ['ocp-node', 'ocp-auth'], # CHG1002832748
  'is_apaasengosev3_bopenshift3enterprise_devuat' => ['ocp-node'],
  'is_apaasengosev3_bopenshift3enterprise_pilot' => ['ocp-node', 'ocp-auth'], # CHG1002832748
  'is_apaas_ecproxyauth_cookbook' => ['ocp-auth'], # CHNG0005102389
  'is_apaas_ecproxylb_pilot' => ['ocp-node'],
  'is_apaas_ecproxylb_prod' => ['ocp-node'], # CHG1000015346
  'is_mw_nginx_main' => ['ocp_critical'], # CHG1001684409.
  'is_iaas_unix_network' => %w[firewalld_enabled iptables_enabled], # CHG1000503012
  'b-auth' => ['ukm_lockdown'], # CHG1004539968
  'is_iaas_rhel_cipehardenbuild' => %w[core-dmz-sag core-dmz-ib dmz], # CHG1006235374
  'is_iaas_rhel_base' => %w[eicp ukm_lockdown core-dmz-ib core-dmz-sag dmz], # CHG1006952451
  'is_iaas_unix_powerbroker' => %w[pb-upgrade], # CHG1006952451
  'is_iaas_aix_base' => %w[eicp ukm_lockdown core-dmz-ib core-dmz-sag dmz] # CHG1010065051
}
# BARC013
@mount_cookbook_whitelist = [
  'ib_smad_are_fx', # CHG1006688196
  'dseng_jira_app_unix', # CHG1012250425
  'dseng_conf_app_unix', # CHG1012250425
  'ds_gitlab_server_ee' # CHG1013932052
]

# BARC017
@system_services_cookbook_whitelist = [
  'coo_ie_bti_sites' # CHG1013747789
]

# BARC021 and audit pipeline configuration
@cookbook_coverage_default = { 'unit_coverage_min' => 93,
                               'unit_total_min' => 5,
                               'inspec_coverage_min' => 100,
                               'inspec_total_min' => 5 }

@cookbook_coverage_whitelist = {
  'cto_esaas_elasticagent_linuxbase' => { 'unit_coverage_min' => 95,
                                          'unit_total_min' => 2,
                                          'inspec_coverage_min' => 100,
                                          'inspec_total_min' => 10 },
  'library_custom_coverage' => { 'unit_coverage_min' => 95,
                                 'unit_total_min' => 3,
                                 'inspec_coverage_min' => 100,
                                 'inspec_total_min' => 10 },
  'b_iac_cc_lvm' => { 'unit_coverage_min' => 0,
                      'unit_total_min' => 0,
                      'inspec_coverage_min' => 100,
                      'inspec_total_min' => 10 },
  'line' => { 'unit_coverage_min' => 0,
              'unit_total_min' => 0,
              'inspec_coverage_min' => 100,
              'inspec_total_min' => 10 },
  'cron' => { 'unit_coverage_min' => 0,
              'unit_total_min' => 0,
              'inspec_coverage_min' => 100,
              'inspec_total_min' => 10 },
  'selinux' => { 'unit_coverage_min' => 0,
                 'unit_total_min' => 0,
                 'inspec_coverage_min' => 100,
                 'inspec_total_min' => 10 },
  'logrotate' => { 'unit_coverage_min' => 0,
                   'unit_total_min' => 0,
                   'inspec_coverage_min' => 100,
                   'inspec_total_min' => 10 },
  'unix-audit-remediation' => { 'unit_coverage_min' => 0,
                                'unit_total_min' => 0,
                                'inspec_coverage_min' => 0,
                                'inspec_total_min' => 0 },
  'is_iaas_unix_network' => { 'unit_coverage_min' => 0,
                              'unit_total_min' => 0,
                              'inspec_coverage_min' => 0,
                              'inspec_total_min' => 0 },
  'is_iaas_unix_remediation' => { 'unit_coverage_min' => 0,
                                  'unit_total_min' => 0,
                                  'inspec_coverage_min' => 100,
                                  'inspec_total_min' => 0 }
}

# Middleware cookbook whitelist used by rule BARC027 (cookbooks authorised to deploy Middleware software)
# Any changes to this whitelist must be authorised by the Middleware team
@mw_cookbook_whitelist = ['chef-openshift3_enterprise',
                          'cookbook-openshift3',
                          'is-apaaseng-osev3-b-openshift3_enterprise',
                          'is-mw-apachehttpd-build',
                          'is_mw_apachehttpd_build2018', # CHG1001194994
                          'is-mw-cd_unix-build',
                          'is-mw-jboss6-build',
                          'is_mw_jboss7_build02',
                          'is-mw-tomcat-build',
                          'is_apaas_openshift_cookbook',
                          'is_apaasengosev3_bopenshift3enterprise_dev',
                          'is_apaasengosev3_bopenshift3enterprise_devuat',
                          'is_apaasengosev3_bopenshift3enterprise_pilot',
                          'corporate_digital_nginx_srv', # CHG1009291887
                          'is_apaasengosev3_bopenshift3enterprise_scripts',
                          'is_mw_activemq_build',
                          'is_mw_amq7_build02', # CHG1001819560
                          'is_mw_daffyforlinux_build',
                          'is_mw_fuse_build',
                          'is_mw_iib10_build',
                          'is_mw_ace_build', # CHG1008241054
                          'is_mw_jboss6_build2018',
                          'is_mw_mq_build',
                          'is_mw_mq91_build02',
                          'is_mw_mq9_echannel', # CHG1011191680
			  'is_cto_nexus_install', # CHG1020658267
			  'is_apaas_v4nginx_lb', # CHG1020658267
                          'is_mw_nginx_build',
                          'is_mw_nginx_main',
                          'is_mw_sds_build',
                          'is_mw_sds_build2018',
                          'is_mw_tomcat8_build2018',
                          'is_mw_tomcat_build2018',
                          'is_mw_was7_build',
                          'is_mw_was8_build',
                          'is_mw_p2pftlinux_build',
                          'is_mw_jwstomcat9_build02',
                          'is_mw_weblogic_build',
                          'is_mw_apachekafka_build02']

# Prevent Middleware packages from being installed by non-approved cookbooks used by rule BARC027
# Any changes to this list must be authorised by the Middleware team
# jq package was added as a part of CR CHG1020070578, INC INC1039987827 was raised to remove it from the list as it was causing some foodcritic issues to app teams.
@mw_pkg_prefixes = ['BCwlserver',
                    'BarcJBoss',
                    'BarcJBossUtils',
                    'BarcMW_DaffyLinux',
                    'BarcMW_IBMIM',
                    'corporate_digital_nginx_srv', # CHG1009200452
		    'BarcPaas-wily-epaagent-binaries-openshift10', # CHG1020070578
                    'BarcMW_IBMSDS',
                    'BarcMW_ISDSLinux',
                    'BarcMW_WAS7',
                    'BarcMW_was7',
                    'BarcMW_was855',
                    'IIB-',
                    'ACE-',
                    'MQSeries',
                    'amq-', # CHG1001819560
                    'httpd',
                    'mod_ssl',
                    'mod_security',
                    'idsldap-license64',
                    'iibsbin',
                    'is-mw-cd_unix-build',
                    'jboss-a-mq',
                    'jboss-fuse',
                    'msgBin',
                    'msgSbin',
                    'msgsecexits',
                    'msgssl',
                    'nginx-plus',
                    'qmaccess',
                    'tomcat',
                    'BarcMW_P2PFT_Sender',
                    'jws5-tomcat',
                    'BarcMW_apachekafka_2_12',
                    'BarcMW_apachekafka_2_13']

# Prevent restricted cookbooks to be used without whitelisting.
# Whitelist cookbooks which could depend on restricted cookbooks.
# Foodcritic rule BARC028
@restricted_cookbook_whitelist = {
  'is_mw_tomcatdmz_build' => ['is_test_foodcritic_dmztomcat', # CHG1000885886
                              'wealth_imst_fids_tomcat6',
                              'wealth_imst_bcfs_tomcat6',
                              'bi_wholesalelending_bookbuilder_externalportal',
                              'bi_wholesalelending_dealvault_externalportal',
                              'ib_tier4_tomcat_investorsolutions',
                              'cft_wps_tomcat_barxterms',
                              'cft_wps_tomcat_barxonline',
                              'integration_ckbk']
}

# Wrapper cookbooks (alowed to access Community cookbooks)
# 1:1 Relationship
@cookbook_wraps = { 'b_iac_cc_test' => 'test',
                    'b_iac_cc_openssl' => 'openssl' }

@community_cookbooks = []
@blocked_cookbooks = []
# @cookbook_wraps.each do |_key, value|
#   @blocked_cookbooks.push('depends' => value)
#   @community_cookbooks.push(value)
# end

# Prevent deprecated cookbooks from being used
# Foodcritic rule BARC030
@deprecated_cookbooks = {
  'b-java' => ['b_iac_cc_java', 'incompatible with Chef 13 see link [Confluence link](https://confluence.barcapint.com/display/CHEFPL01/b_iac_cc_java+-+Management+of+JDK+or+JRE+on+Linux)'],
  'java' => ['b_iac_cc_java', 'incompatible with Chef 13 see link [Confluence link](https://confluence.barcapint.com/display/CHEFPL01/b_iac_cc_java+-+Management+of+JDK+or+JRE+on+Linux)']
}

# Restrict access to install controlled packages rule #BARC031
@controlled_packages = {
  'jre' => {
    'whitelist' => [
      'b_iac_cc_java'
    ]
  },
  'jdk' => {
    'whitelist' => [
      'b_iac_cc_java'
    ]
  }
}

# @orac_java_hard_pined_up = { '<yourcookbook>' => 'ORAC' }
@orac_java_hard_pined_up = {
  'pcb_bcus_chat_click2chat' => 'ORAC-I0049078', # CR CHG1003590214 - Java version 181 needed for legacy application deployment.
  'is_mw_jboss6_pegauat' => 'ORAC-I0052998', # CHG1003694255  JDK 1.8 version 162 needed for Pega  application deployment.
  'bcus_apipltf_tiaa_java' => 'ISSUE-00055019', # CHG1004052728 JDK 1.8 version 241 needed for TIAA ping federate application
  'bcus_devops_xapi_akana' => 'ISSUE-00055019', # CHG1004512024 JDK 1.8 version 222 needed for Akana application
  'gis_tiaaengineering_tiaa_aaaws' => 'ISSUE-00055019', # CHG1004208884 JDK 1.8 version 241 needed for TIAA PingFederate application deployment
  'barclaysint_fml_rsa_tomcat' => 'ISSUE-00045828', # CHG1004152921 openjre_zulu8_0 262 to support RSA Legacy (BCUS)
  'coo_clmt_jetbridge_jboss6' => 'TC01-004', # CHG1007679619 JDK 1.8 version 112 needed for Jetbridge 1 Pega application
  'is_mw_jboss6_custcon' => 'ISSUE-00069450', # CHG1012350438 Java version 202 needed for legacy jboss 6 jvm starts
}

# Prevent use of unsupported cookbook versions rule #BARC032
@cookbook_minimum_versions = {
  'b_iac_cc_java' => '0.2.10',
  'ib_cto_ca_nolio' => '6.6.10'
}

# Allow only specified pin methods via depends for following cookbooks
# Whitelist primary cookboooks that pull these in
# cookbook_name => Array of allowed pin methods
# These coobooks should be available in all chef runs by default
# There should be no requirement of pin them
# If needed an integration cookbook can be used to pull them into test kitchen

# Whitelist of primary cookbooks that set versions for runlist
@whitelist_cookbook_allowed_pins_only = [
  'barclays-base',
  'b_unix_base_core',
  'b_unix_base_ech',
  'b_unix_base_common'
]

# Block list of Infra cookbooks
@cookbook_allowed_pins_only = {
  # Core Infrastructure cookbooks
  'b_unix_base_core' => ['>=', '~>'],
  'b_unix_base_ech' => ['>=', '~>'],
  'b_unix_base_common' => ['>=', '~>'],
  'b_all_production_blocker' => ['>=', '~>'],
  'b-rhel7-latest' => ['>=', '~>'],
  'paas_mw_corebase_prod' => ['>=', '~>'],
  'chef-client' => ['>=', '~>'],
  'b-users_manage' => ['>=', '~>'],
  'iaas_unix_ilmt_agent' => ['>=', '~>'],
  'is_iaas_unix_ssl' => ['>=', '~>'],
  'is_uisec_unix_sudo' => ['>=', '~>'],
  'is_iaas_unix_estatescripts' => ['>=', '~>'],
  'unix-audit-remediation' => ['>=', '~>'],
  'is_iaas_unix_remediation' => ['>=', '~>'],
  'barclays-security-audit-rhel' => ['>=', '~>'],
  'chef_handler' => ['>=', '~>'],
  'b-omnibus_updater' => ['>=', '~>'],
  'b-vas_manage' => ['>=', '~>'],
  'is_iaas_unix_syslog' => ['>=', '~>'],
  'is_iaas_unix_ntp' => ['>=', '~>'],
  'is_iaas_unix_fixhptools' => ['>=', '~>'],
  'barclays-incident-fixes' => ['>=', '~>'],
  'is_uisec_service_watch' => ['>=', '~>'],
  'insv_eme_tanium_client' => ['>=', '~>'],
  'iaas_unix_sysipcpr_local' => ['>=', '~>'],
  'b-rhel7-build' => ['>=', '~>'],
  'b-auth' => ['>=', '~>'],
  'b-identification' => ['>=', '~>'],
  'b-monitoring' => ['>=', '~>'],
  'b-build-compliance' => ['>=', '~>'],
  'is_mw_software_compliance' => ['>=', '~>']
}

####################
# common functions #
####################

def xpath_to_s(cmd)
  unless cmd.is_a? String
    # extract tstring_content values from execute -> command leaf
    return cmd.xpath('.//tstring_content/@value').map(&:text).join("\n")
  end

  cmd
end

def xpath_static_string_to_s(cmd)
  unless cmd.is_a? String
    # extract static tstring_content values from ast
    return cmd.xpath('.//string_literal/string_add/string_add/tstring_content/@value').map(&:text).join("\n")
  end

  cmd
end

def unix_forbidden_in_cmd(forbidden_commands, cmd_str)
  # split on endline, | pipe, & separator, (; separator)
  cmd_str = xpath_to_s(cmd_str).split(/\n|\||&|;/)
  forbidden_commands.any? do |cmd|
    cmd_str.any? do |line|
      # asumes that blacklisted command does not have space
      command = line.lstrip.downcase.split.first
      next unless command

      # change forward to backslash,
      # remove ()
      # get executable name,
      # check if it equals blacklisted command
      command.tr('\\', '/').gsub(/\(|\)/, '').split('/').last.eql?(cmd)
    end
  end
end

def win_forbidden_in_cmd(forbidden_commands, cmd_str)
  # split on endline, | pipe, & separator, (; separator)
  cmd_str = xpath_to_s(cmd_str).split(/\n|\|/)
  forbidden_commands.any? do |cmd|
    cmd_str.any? { |line| line.lstrip.downcase.start_with? cmd } ||
    cmd_str.any? { |line| line.lstrip.downcase.match('^((\w+\s|\w?\W*)?|(\/\w+\/?)*)?(' + cmd + ')\b[ \/\w\-]*$') } ||
    cmd_str.any? { |line| line.lstrip.downcase.match('\$*\.' + cmd) } # Match .NET function called from Powershell
  end
end

# Chef resource and attribute combinations to check
# keys - Chef resource attributes
# values - Chef resources
@attr_conf_unix_main = { 'command' => %w[execute cron cron_d],
                         'code' => %w[bash script] }
@attr_conf_unix_notnameresource = { 'init_command' => ['service'],
                                    'reload_command' => ['service'],
                                    'restart_command' => ['service'],
                                    'start_command' => ['service'],
                                    'stop_command' => ['service'] }

@attr_conf_win_main = { 'command' => %w[execute],
                        'code' => %w[batch powershell_script] }
@attr_conf_win_notnameresource = { 'init_command' => ['service'],
                                   'reload_command' => ['service'],
                                   'restart_command' => ['service'],
                                   'start_command' => ['service'],
                                   'stop_command' => ['service'] }

@file_resource_types = %w[
  file
  template
  remote_file
  cookbook_file
  remote_directory
  directory
  append_if_no_line
  replace_or_add
  delete_lines
  add_to_list
  delete_from_list
]

def find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
  # Unix specific check for resources
  # Unix specific check for resources
  violations = []
  @attr_conf_unix_main.each_pair do |item, resource_types|
    resource_types.each do |resource_type|
      violations << find_resources(ast, type: resource_type).select do |cmd|
        cmd_str = (resource_attribute(cmd, item) || resource_name(cmd))
        next unless cmd_str

        unless @cmd_whitelist.include?(cmd_str) &&
              (@cmd_whitelist[cmd_str].empty? || @cmd_whitelist[cmd_str].include?(ckbname))
          unix_forbidden_in_cmd(unix_forbidden_cmds, cmd_str)
        end
      end
    end
  end
  @attr_conf_unix_notnameresource.each_pair do |item, resource_types|
    resource_types.each do |resource_type|
      violations << find_resources(ast, type: resource_type).select do |cmd|
        cmd_str = resource_attribute(cmd, item)
        next unless cmd_str

        unless @cmd_whitelist.include?(cmd_str) &&
              (@cmd_whitelist[cmd_str].empty? || @cmd_whitelist[cmd_str].include?(ckbname))
          unix_forbidden_in_cmd(unix_forbidden_cmds, cmd_str)
        end
      end
    end
  end
  violations.flatten
end

def find_violations_cmd_win(ast, win_forbidden_cmds, ckbname)
  # Windows specific check for resources w additional check
  violations = []
  @attr_conf_win_main.each_pair do |item, resource_types|
    resource_types.each do |resource_type|
      violations << find_resources(ast, type: resource_type).select do |cmd|
        cmd_str = (resource_attribute(cmd, item) || resource_name(cmd))
        cmd_str = cmd_str.strip.downcase if cmd_str.is_a?(String)
        next unless cmd_str

        unless @cmd_whitelist.include?(cmd_str) &&
              (@cmd_whitelist[cmd_str].empty? || @cmd_whitelist[cmd_str].include?(ckbname))
          win_forbidden_in_cmd(win_forbidden_cmds, cmd_str)
        end
      end
    end
  end
  @attr_conf_win_notnameresource.each_pair do |item, resource_types|
    resource_types.each do |resource_type|
      violations << find_resources(ast, type: resource_type).select do |cmd|
        cmd_str = resource_attribute(cmd, item)
        next unless cmd_str

        unless @cmd_whitelist.include?(cmd_str) &&
              (@cmd_whitelist[cmd_str].empty? || @cmd_whitelist[cmd_str].include?(ckbname))
          win_forbidden_in_cmd(win_forbidden_cmds, cmd_str)
        end
      end
    end
  end
  violations.flatten
end

def berks_dependency_islibrary?(dep_name)
  return false unless File.exist?('Berksfile')

  require 'berkshelf'
  berkshelf = Berkshelf::Berksfile.from_file('Berksfile')
  berkshelf.update if File.exist?('Berksfile.lock')
  berkshelf.install unless File.exist?('Berksfile.lock')
  berkshelf.list.each do |dep|
    return true if dep.name == dep_name &&
                   dep.cached_cookbook.metadata.respond_to?('platforms') &&
                   dep.cached_cookbook.metadata.platforms.include?('b_cookbook_pipeline_library')
  end
  false
end

# Returns variable assignments from the ast which match the string passed
# Three check types equals, starts and contains
def get_var_assignments(ast, string, check_type)
  results = []
  case check_type
  when 'equals'
    xpath_selector = "descendant::tstring_content[@value=\"#{string}\"]"
  when 'starts'
    xpath_selector = "descendant::tstring_content[starts-with(@value, \"#{string}\")]"
  when 'contains'
    xpath_selector = "descendant::tstring_content[contains(@value, \"#{string}\")]"
  else
    abort "Invalid check_type #{check_type}"
  end
  xpath = "//assign/string_literal[@value='string_literal']/#{xpath_selector}/ancestor::assign[@value='assign']/var_field/ident[@value]|"\
          "//assign/array[@value='array']/#{xpath_selector}/ancestor::assign[@value='assign']/var_field/ident[@value]|"\
          "//assign/hash[@value='hash']/#{xpath_selector}/ancestor::assign[@value='assign']/var_field/ident[@value]|"\
          "//assign/#{xpath_selector}/ancestor::assign[@value='assign']/var_field/const[@value]|"\
          "//method_add_block/call[@value='.']/array[@value='array']/#{xpath_selector}/ancestor::call[@value='.']/following-sibling::do_block/block_var/params/descendant::ident[@value]"
  matches = ast.xpath(xpath)
  unless matches.empty?
    matches.each do |match|
      results.push(match.values[0])
    end
  end
  results
end

# Returns variable to variabls assignments from the ast which match the string passed
def get_var2var_assignments(ast, string)
  results = []
  xpath = "//assign/var_ref[@value='var_ref']/const[@value=\"#{string}\"]/ancestor::assign[@value='assign']/var_field/ident[@value]|"\
          "//assign/var_ref[@value='var_ref']/ident[@value=\"#{string}\"]/ancestor::assign[@value='assign']/var_field/ident[@value]|"\
          "//assign/hash/assoclist_from_args/assoc_new/ident[@value=\"#{string}\"]/ancestor::assign[@value='assign']/var_field/ident[@value]|"\
          "//assign/hash/assoclist_from_args/assoc_new/const[@value=\"#{string}\"]/ancestor::assign[@value='assign']/var_field/ident[@value]|"\
          "//assign/array/args_add/descendant::var_ref/ident[@value=\"#{string}\"]/ancestor::assign[@value='assign']/var_field/ident[@value]|"\
          "//assign/array/args_add/descendant::var_ref/const[@value=\"#{string}\"]/ancestor::assign[@value='assign']/var_field/ident[@value]|"\
          "//method_add_block/call[@value='.']/var_ref/ident[@value=\"#{string}\"]/ancestor::call[@value='.']/following-sibling::do_block/block_var/params/descendant::ident[@value]"
  matches = ast.xpath(xpath)
  unless matches.empty?
    matches.each do |match|
      results.push(match.values[0])
      child_results = get_var2var_assignments(ast, match.values[0])
      results += child_results
    end
  end
  results
end

# Adapted foodcritic find_resources method to find 1liner resources (Those with no do block)
def find_1liner_resources(ast, options = {})
  options = { type: :any }.merge!(options)
  return [] unless ast.respond_to?(:xpath)

  scope_type = ''
  scope_type = "[@value='#{options[:type]}']" unless options[:type] == :any

  block_resources = ast.xpath("//method_add_block//command[not(following-sibling::*)]/ident#{scope_type}/..")
  ast.xpath("//command[not(following-sibling::*)]/ident#{scope_type}/..") - block_resources
end

# Multiple package/resource names can be defined for a single resource,
# this function should return an Array containing all of the names
def get_package_names(resource)
  results = []
  pkg_name = resource_attribute(resource, 'package_name')
  pkg_fragment = Nokogiri::XML.fragment(resource)

  case pkg_name.class.to_s
  when 'String'
    results.push(pkg_name)
  when 'Nokogiri::XML::Element'
    pkg_names = pkg_fragment.xpath("method_add_block/do_block/descendant::command/ident[@value='package_name']/following-sibling::args_add_block/descendant::array/descendant::tstring_content/@value")
    results.push(pkg_names)
  else
    pkg_names = pkg_fragment.xpath('method_add_block/command/descendant::tstring_content/@value|command/descendant::tstring_content/@value')
    results.push(pkg_names)
  end
  results.flatten
end

# Do not manipulate a user locally
rule 'BARC001', 'Do not manipulate users locally, use Active Directory instead' do
  tags %w[barc unix windows security]
  recipe do |ast, filename|
    unix_forbidden_cmds = %w[
      useradd
      usermod
      userdel
      passwd
    ]
    win_forbidden_cmds = [
      'create\([\'"]user[\'"]', # .NET functions called from Powershell - must be supplied as escaped RegEX
      'net user'
    ]
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)
    next if @local_access_cookbook_whitelist.include?(ckbname)

    violations << find_resources(ast, type: 'user')
    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations << find_violations_cmd_win(ast, win_forbidden_cmds, ckbname)
    violations.flatten
  end
end

# Do not manipulate a group locally
rule 'BARC002', 'Do not manipulate groups locally, use Active Directory instead' do
  tags %w[barc unix windows security]
  recipe do |ast, filename|
    unix_forbidden_cmds = %w[
      groupadd
      groupmod
      groupdel
    ]
    win_forbidden_cmds = [
      'create\([\'"]group[\'"]', # .NET functions called from Powershell - must be supplied as escaped RegEX
      'net group',
      'net localgroup'
    ]
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)
    next if @local_access_cookbook_whitelist.include?(ckbname)

    violations << find_resources(ast, type: 'group')
    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations << find_violations_cmd_win(ast, win_forbidden_cmds, ckbname)
    violations.flatten
  end
end

# Avoid touching files in .ssh for root user
rule 'BARC003', 'Do not manipulate any file in .ssh for root user' do
  tags %w[barc unix security]
  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    @file_resource_types.each do |resource_type|
      violations << find_resources(ast, type: resource_type).select do |resource|
        resource_name(resource).start_with?('/root/.ssh') ||
        (resource_attribute(resource, 'path') &&
        (path_str = resource_attribute(resource, 'path')
         unless path_str.is_a? String
           path_str = path_str.xpath('.//tstring_content/@value').map(&:text).join('')
         end
         path_str.start_with?('/root/.ssh')
        )
        )
      end
    end
    violations.flatten
  end
end

# We do not allow users to modify any private or public keys as well as the authorized_keys file. We will only allow them to modify known_hosts.
rule 'BARC004', 'Avoid manipulating ssh keys for any user' do
  tags %w[barc unix security]
  recipe do |ast, filename|
    unix_forbidden_cmds = %w[
      ssh-keygen
      ssh-add
    ]
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    @file_resource_types.each do |resource_type|
      violations << find_resources(ast, type: resource_type).select do |resource|
        file_path = (resource_attribute(resource, 'path') || resource_name(resource)).to_s
        file_path.match(%r{\/users\/.+\/.ssh}) && !file_path.end_with?('known_hosts')
      end
    end
    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations.flatten
  end
end

# Updated BARC005 to use a blacklist of files/directories in /etc that must not be adjusted
rule 'BARC005', 'Do not manipulate any existing file or directory in the blacklist' do
  tags %w[barc unix security]
  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    @file_resource_types.each do |resource_type|
      violations << find_resources(ast, type: resource_type).select do |resource|
        res_str = (resource_attribute(resource, 'path') || resource_name(resource)).to_s
        unless @etc_whitelist.include?(res_str) &&
              (@etc_whitelist[res_str].empty? || @etc_whitelist[res_str].include?(ckbname))
          @etc_blacklist.any? { |cmd| res_str.include? cmd }
        end
      end
    end
    violations.flatten
  end
end

# Extension of new BARC005 rules to detect attributes using blacklisted files or directories in /etc
rule 'BARC005a', 'Do not use attributes to manipulate any existing file or directory in the blacklist' do
  tags %w[barc unix security]
  cookbook do |path|
    next if @platform_cookbook_whitelist.include?(cookbook_name("#{path}/metadata.rb"))

    recipes = Dir["#{path}/attributes/*.rb"]
    recipes.collect do |recipe|
      lines = File.readlines(recipe)
      lines.collect.with_index do |line, index|
        unless @etc_whitelist.any? { |key, cookbooks| line.include?(key) && (cookbooks.include?(cookbook_name(recipe)) || cookbooks.empty?) }
          if @etc_blacklist.any? { |cmd| line.include? cmd }
            {
              filename: recipe,
              matched: recipe,
              line: index + 1,
              column: 0
            }
          end
        end
      end.compact
    end.flatten
  end
end

# Don't halt, shutdown, reboot, or poweroff a node
rule 'BARC006', 'Do not halt, shutdown, reboot, or poweroff a node' do
  tags %w[barc unix windows security]
  unix_forbidden_cmds = [
    'halt',
    'shutdown',
    'reboot',
    'poweroff',
    'systemctl shutdown',
    'systemctl poweroff',
    'systemctl halt',
    'systemctl reboot'
  ]
  win_forbidden_cmds = %w[
    stop-computer
    restart-computer
    shutdown
  ]
  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)
    next if @reboot_cookbook_whitelist.include?(ckbname)

    violations << find_resources(ast, type: 'reboot')
    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations << find_violations_cmd_win(ast, win_forbidden_cmds, ckbname)
    violations.flatten
  end
end

# Don't change SELinux configurations
rule 'BARC007', 'Do not manipulate SELinux' do
  tags %w[barc unix security]
  unix_forbidden_cmds = %w[
    chcon
    semanage
    setenforce
    setsebool
    togglesebool
    setfiles
  ]
  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)
    next if @selinux_cookbook_whitelist.include?(ckbname)

    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations.flatten
  end
end

# Don't kill or change the priority of a process
rule 'BARC008', 'Do not kill or change the priority of a process' do
  tags %w[barc unix windows security]
  unix_forbidden_cmds = %w[
    kill
    pkill
    killall
    killall5
    nice
    renice
  ]
  win_forbidden_cmds = %w[
    pskill
    taskkill
  ]
  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations << find_violations_cmd_win(ast, win_forbidden_cmds, ckbname)
    violations.flatten
  end
end

# Don't manipulate firewalls
rule 'BARC009', 'Do not manipulate firewalls' do
  tags %w[barc unix windows security]
  unix_forbidden_cmds = %w[
    firewall-cmd
    firewall-config
    iptables
  ]
  win_forbidden_cmds = [
    'netsh firewall',
    'netsh advfirewall',
    'set-netfirewall',
    'set-netipsec',
    'disable-netfirewall',
    'disable-netipsec',
    'enable-netipsec',
    'new-netfirewall',
    'remove-netfirewall'
  ]
  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    violations << find_resources(ast, type: 'service').select do |svc|
      svc_name = (resource_attribute(svc, 'service_name') || resource_name(svc)).to_s
      %w[iptables mpssvc policyagent].include? svc_name.to_s.downcase
    end
    violations << find_resources(ast, type: 'windows_service').select do |svc|
      svc_name = (resource_attribute(svc, 'service_name') || resource_name(svc)).to_s
      %w[mpssvc policyagent].include? svc_name.to_s.downcase
    end
    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations << find_violations_cmd_win(ast, win_forbidden_cmds, ckbname)
    violations.flatten
  end
end

# Don't use init or telinit
rule 'BARC010', 'Do not use init or telinit' do
  tags %w[barc unix security]
  unix_forbidden_cmds = %w[init telinit]
  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations.flatten
  end
end

# Don't delete a file or directory, or convert and copy a file
rule 'BARC011', 'Do not remove files/directories, or convert and copy a file' do
  tags %w[barc unix windows security]
  unix_forbidden_cmds = %w[
    rm
    rmdir
    dd
  ]
  win_forbidden_cmds = %w[
    del
    erase
    deltree
    remove-item
  ]

  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations << find_violations_cmd_win(ast, win_forbidden_cmds, ckbname)
    violations.flatten
  end
end

# Don't manipulate kernel
rule 'BARC012', 'Do not manipulate operating system kernel' do
  tags %w[barc unix security]
  unix_forbidden_cmds = %w[
    kexec
    sysctl
    modprobe
    insmod
    rmmod
  ]
  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations.flatten
  end
end

# Don't manipulate volume, partition, and devices of the file system
rule 'BARC013', 'Do not manipulate volumes, partitions, and devices of the file system' do
  tags %w[barc unix windows security]
  unix_forbidden_cmds = %w[
    lvremove
    pvremove
    vgremove
    mkfs
    wipefs
    umount
    mount
    delpart
    addpart
    partx
    kpartx
    parted
    partprobe
    fdisk
    fsck
  ]
  win_forbidden_cmds = %w[
    diskpart
    format
    clear-disk
    new-partition
    remove-partition
    remove-physicaldisk
    set-partition
  ]
  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    unless @mount_cookbook_whitelist.include?(ckbname)
      violations << find_resources(ast, type: 'mount')
    end
    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations << find_violations_cmd_win(ast, win_forbidden_cmds, ckbname)
    violations.flatten
  end
end

# Don't manipulate network
rule 'BARC014', 'Do not manipulate network' do
  tags %w[barc unix windows security]
  unix_forbidden_cmds = %w[
    ifup
    ifdown
    ip
    ifcfg
    ifconfig
    ifenslave
    ethtool
    route
  ]
  win_forbidden_cmds = [
    'route ',
    'netsh ',
    'set-netipaddress',
    'set-netipinterface',
    'set-netipv4protocol',
    'set-netipv6protocol',
    'set-netroute',
    'set-nettcpsetting',
    'set-netudpsetting',
    'remove-netroute',
    'remove-netipaddress'
  ]
  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    %w[ifconfig route].each do |resource_type|
      violations << find_resources(ast, type: resource_type)
    end
    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations << find_violations_cmd_win(ast, win_forbidden_cmds, ckbname)
    violations.flatten
  end
end

# Don't modify root crontab
rule 'BARC015', 'Do not manipulate root cron jobs' do
  tags %w[barc unix security]
  unix_forbidden_cmds = [
    'crontab'
  ]
  forbidden_users = [
    'root',
    ''
  ]
  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)

    # Platform cookbooks get full exemption from ALL check
    next if @platform_cookbook_whitelist.include?(ckbname)

    # Check cron/cron_d resources (with targeted exemption)
    unless @cron_root_whitelist.include?(ckbname)
      %w[cron cron_d].each do |res_type|
        violations << find_resources(ast, type: res_type).select do |cron|
          user = resource_attribute(cron, 'user')
          user = if user.is_a?(String)
                  [user]
                elsif !user.nil?
                  xpath_static_string_to_s(user).split(/\n|\||&|;/)
                else
                  ['root']
                end
          next if !user.size.zero? && forbidden_users.none? { |name| user.include?(name) }

          cron
        end
      end
    end

    @file_resource_types.each do |resource_type|
      violations << find_resources(ast, type: resource_type).select do |resource|
        resource_name(resource).start_with?('/var/spool/cron') ||
        (resource_attribute(resource, 'path') &&
        (path_str = resource_attribute(resource, 'path')
         unless path_str.is_a? String
           path_str = path_str.xpath('.//tstring_content/@value').map(&:text).join('')
         end
         path_str.start_with?('/var/spool/cron')
        )
        )
      end
    end
    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations.flatten
  end
end

# Do not use service, yum or rpm command, use the corresponding chef resource instead
rule 'BARC016', 'Do not use service or yum command, use the corresponding chef resource instead' do
  tags %w[barc unix style]
  unix_forbidden_cmds = %w[
    service
    yum
    rpm
  ]
  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname) || @rpm_cookbook_whitelist.include?(ckbname)

    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations.flatten
  end
end

# Commands that should not be used for both system services and restricted services
service_commands = ['chkconfig', 'stop-service', 'net stop', 'net.exe stop',
                    'set-service', 'sc delete', 'sc.exe delete',
                    'sc stop', 'sc.exe stop', 'sc configure', 'sc.exe configure']

# Don't manipulate system services
rule 'BARC017', 'Do not manipulate system services' do
  tags %w[barc unix windows security]
  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)
    next if @system_services_cookbook_whitelist.include?(ckbname)

    violations << find_resources(ast, type: 'service').select do |svc|
      svc_name = (resource_attribute(svc, 'service_name') || resource_name(svc)).to_s
      @system_services.include? svc_name.to_s.downcase
    end
    violations << find_resources(ast, type: 'windows_service').select do |svc|
      svc_name = (resource_attribute(svc, 'service_name') || resource_name(svc)).to_s
      @system_services.include? svc_name.to_s.downcase
    end
    violations << find_resources(ast, type: 'execute').select do |exe|
      cmd_str = (resource_attribute(exe, 'command') || resource_name(exe)).to_s
      service_commands.any? do |svc_cmd|
        (cmd_str.to_s.downcase.include? svc_cmd) && @system_services.any? { |svc| cmd_str.to_s.downcase.include? svc }
      end
    end
    %w[bash script batch powershell_script].each do |resource_type|
      violations << find_resources(ast, type: resource_type).select do |bash|
        code_str = resource_attribute(bash, 'code')
        next unless code_str

        unless code_str.is_a? String
          code_str = code_str.xpath('.//tstring_content/@value').map(&:text).join('')
        end
        service_commands.any? do |svc_cmd|
          (code_str.to_s.downcase.include? svc_cmd) && @system_services.any? { |svc| code_str.to_s.downcase.include? svc }
        end
      end
    end
    violations.flatten
  end
end

# This rule will detect any services that are not on neither the blacklist nor the whitelist. It will warn users to review the detected services.
# After review, the service is expected to be added into either the whitelist or blacklist.
rule 'BARC018', 'Please review this service' do
  tags %w[barc unix svc]
  def resource_service_concat(svc)
    svc.xpath('.//command').each do |item|
      unless item.xpath('.//ident[@value="service"]').empty?
        result = item.xpath('.//tstring_content/@value').map(&:text).join('')
        return result
      end
    end
  end

  def resource_service_restricted?(cmd_str, filename)
    @restricted_services.any? { |svc| cmd_str.include?(svc[0]) && !svc[1].empty? && !svc[1].include?(cookbook_name(filename)) }
  end

  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    violations << find_resources(ast, type: 'service').select do |svc|
      svc_name = (resource_attribute(svc, 'service_name') || resource_service_concat(svc))
      next unless svc_name

      unless svc_name.is_a? String
        svc_name = svc_name.xpath('.//tstring_content/@value').map(&:text).join('')
      end
      !@system_services.include?(svc_name) &&
      !(!@restricted_services.include?(svc_name) || @restricted_services[svc_name].empty? || @restricted_services[svc_name].include?(cookbook_name(filename))
       )
    end
    violations << find_resources(ast, type: 'execute').select do |exe|
      cmd_str = (resource_attribute(exe, 'command') || resource_name(exe)).to_s
      service_commands.any? do |svc_cmd|
        (cmd_str.to_s.downcase.include? svc_cmd) && @system_services.none? { |svc| cmd_str.to_s.downcase.include? svc } &&
        resource_service_restricted?(cmd_str, filename)
      end
    end
    %w[bash script batch powershell_script].each do |resource_type|
      violations << find_resources(ast, type: resource_type).select do |bash|
        code_str = resource_attribute(bash, 'code')
        next unless code_str

        unless code_str.is_a? String
          code_str = code_str.xpath('.//tstring_content/@value').map(&:text).join('')
        end
        service_commands.any? do |svc_cmd|
          (code_str.to_s.downcase.include? svc_cmd) && @system_services.none? { |svc| code_str.to_s.downcase.include? svc } &&
          resource_service_restricted?(code_str, filename)
        end
      end
    end
    violations << find_resources(ast, type: 'systemd_unit').select do |unit|
      unit_name = (resource_attribute(unit, 'name') || resource_name(unit))
      next unless unit_name

      unless unit_name.is_a? String
        unit_name = unit_name.xpath('.//tstring_content/@value').map(&:text).join('')
      end
      unit_name = unit_name.gsub(/(\.service$|\.socket$|\.target$|\.timer$)/, '')
      !@system_services.include?(unit_name) &&
      !(!@restricted_services.include?(unit_name) ||
        @restricted_services[unit_name].empty? ||
        @restricted_services[unit_name].include?(cookbook_name(filename))
       )
    end
    violations.flatten
  end
end

# Don't use find and sudo
rule 'BARC019', 'Do not use find and sudo' do
  tags %w[barc unix security]
  unix_forbidden_cmds = %w[
    find
    sudo
  ]
  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations.flatten
  end
end

# Don't use misc forbidden commands
rule 'BARC020', 'Do not use fuser, setfacl, wall, smbclient' do
  tags %w[barc unix security]
  unix_forbidden_cmds = %w[
    fuser
    setfacl
    wall
    smbclient
  ]
  recipe do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    violations << find_violations_cmd_unix(ast, unix_forbidden_cmds, ckbname)
    violations.flatten
  end
end

# We mark this rule as security because if we do not specify an exact version, when a new non-backward compatible
# version of that cookbook is released to prod, the new version of that cookbook could break our nodes.
rule 'BARC021', 'Please specify the exact version in cookbook dependency' do
  tags %w[barc unix windows security]
  metadata do |ast|
    deps = field(ast, 'depends')
    unversioned_deps = []
    deps.each do |dep|
      d = dep.xpath(".//tstring_content[contains(@value, '=') and not(contains(@value, '>')) and not(contains(@value, '<'))]")
      # d returns result when xpath query finds strict pin =
      next if d && !d.empty?

      dep_name = dep.xpath('.//tstring_content/@value').map(&:text).first
      # we allow cookbooks to pass with non-strict dependency declaration against:
      # * whitelisted in @cookbook_coverage_whitelist
      # * dependencies that declare "supports 'b_cookbook_pipeline_library'"
      # cookbook tests are enforced further down the pipeline
      unversioned_deps << dep unless @cookbook_coverage_whitelist.include?(dep_name) ||
                                     berks_dependency_islibrary?(dep_name)
    end
    unversioned_deps
  end
end

# Check for statements that force chef-client exit and break further recipes and converge
rule 'BARC022', 'Do not force chef-client exit, this stops other recipes' do
  tags %w[barc unix windows security]
  statements = {
    'raise' => '//*[self::vcall or self::var_ref or self::command]/ident[@value="raise"]',
    'fail' => '//*[self::vcall or self::var_ref or self::command]/ident[@value="fail"]',
    'Chef::Application.fatal!' => '//call[@value="."]//const[@value="Chef"]/../../const[@value="Application"]/../../ident[@value="fatal!"]'
  }
  def statement_deny(ast, xpath_entry)
    ast.xpath(xpath_entry)
  end
  recipe do |ast, filename|
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    violations = []
    statements.each_pair do |_key, value|
      violations << statement_deny(ast, value)
    end
    violations.flatten
  end
end

# Check if metadata.rb file contains any supported platforms
rule 'BARC023', 'Please specify the cookbook supported platform by providing supports setting in the metadata' do
  tags %w[barc unix windows metadata]
  metadata do |ast, filename|
    [file_match(filename)] unless field(ast, 'supports').any?
  end
end

# Check if metadata.rb file contains required metadata parameters
# maintainer: is a valid string
# maintainer_email: valid@email.entry
# source_url: http(s) url with cookbook name
rule 'BARC024', 'Please specify valid maintainer, maintainer_email and source_url in the metadata' do
  tags %w[barc unix windows metadata]
  metadata do |ast, filename|
    violations = []
    [
      { 'maintainer' => '\A[^0-9`!@#\$%\^&*+_=]+\z' },
      { 'maintainer_email' => '\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z' },
      { 'source_url' => '^(http(s)?):\/\/[(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)' },
      { 'source_url' => "(#{cookbook_name(filename)})" }
    ].each do |metadata_hash|
      vfield = metadata_hash.keys[0]
      vcheck = metadata_hash.values[0]
      # missing field is violation
      violations << [file_match(filename)] if field(ast, vfield).empty?
      # not matching field is violation
      violations << field(ast, vfield) unless !field_value(ast, vfield).nil? &&
                                              field_value(ast, vfield) =~ Regexp.new(vcheck)
    end
    violations.flatten
  end
end

# Check if tags are used
# Identify any unapproved tags in use
rule 'BARC025', 'Unauthorised usage of node tags detected' do
  tags %w[barc unix windows security]
  violations = []
  tag_pattern = '//*[self::fcall/ident[@value=\'tag\']]/parent::* | //*[self::command/ident[@value=\'tag\']]'

  def tag_check(ast, xpath_entry)
    ast.xpath(xpath_entry)
  end

  def ignore_tag(nodeset, tag)
    nodeset.xpath("//*[self::method_add_arg/arg_paren/args_add_block/args_add/string_literal/string_add/tstring_content[@value=\'#{tag}\'] or self::qwords_add/tstring_content[@value=\'#{tag}\']]")
  end

  recipe do |ast, filename|
    next if tag_check(ast, tag_pattern).empty?

    cbk = cookbook_name(filename)
    tag_line = tag_check(ast, tag_pattern)
    tags = tag_line.to_s.scan(/tstring_content value=.(\w+)/).flatten
    approved_tags = @tag_whitelist[cbk] || []
    unapproved_tags = tags - approved_tags
    if @tag_whitelist.key?(cbk)
      @tag_whitelist[cbk].each do |tag|
        tag_line -= ignore_tag(tag_line, tag)
      end
    end

    violations << tag_line unless unapproved_tags.empty?
  end
  violations.flatten
end

# Identify any node.save actions used within recipe
rule 'BARC026', 'Cookbook uses node.save to save partial node data to the chef-server mid-run' do
  tags %w[barc windows]
  def node_saves(ast)
    ast.xpath('//call[(vcall|var_ref)/ident/@value="node"]
    [ident/@value="save"]')
  end
  recipe do |ast, filename|
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    node_saves(ast)
  end
  library do |ast, filename|
    ckbname = cookbook_name(filename)
    next if @platform_cookbook_whitelist.include?(ckbname)

    node_saves(ast)
  end
end

rule 'BARC027', 'Only approved cookbooks can deploy Middleware owned software' do
  tags %w[barc middleware unix]

  mw_pkg_expressions = @mw_pkg_prefixes.map { |prefix| Regexp.new("^#{prefix}.*") }
  @mw_union = Regexp.union(mw_pkg_expressions)

  def check_pkg_name_matches(resource)
    pkg_names = get_package_names(resource)
    pkg_names.each do |pkg|
      return true if @mw_union.match(pkg)
    end
    false
  end

  def get_var_names(ast)
    var_names = []
    var2var_names = []
    # For each Middleware package prefix look for variable assignments that match the prefix
    # Record the variable names for later use in var_names
    @mw_pkg_prefixes.each do |prefix|
      var_names.push(get_var_assignments(ast, prefix, 'starts'))
      var_names.flatten!
    end
    # Lets ensure we have a unique list of var_names
    var_names.uniq!
    # Lets check for var2var assignments
    var_names.each do |var_name|
      var2var_names.push(get_var2var_assignments(ast, var_name))
      var2var_names.flatten!
    end
    var_names += var2var_names
    var_names.uniq!
    var_names
  end

  def check_var_name_matches(resource, var_names)
    pkg_fragment = Nokogiri::XML.fragment(resource)
    # For each variable picked up lets look for resources that use it
    var_names.each do |var_name|
      var_xpath = "method_add_block/descendant::command[@value='command']/args_add_block/args_add/descendant::var_ref[@value='var_ref']/ident[@value=\"#{var_name}\"]|command/args_add_block/args_add/descendant::var_ref[@value='var_ref']/ident[@value=\"#{var_name}\"]"
      var_match = pkg_fragment.xpath(var_xpath)
      # If we get a match lets return true
      return true unless var_match.empty?
    end
    false
  end

  recipe do |ast, filename|
    var_names = get_var_names(ast)
    cookbookname = cookbook_name(filename)
    pkg_res = find_resources(ast, type: :package).select do |pkg|
      var_name_match = check_var_name_matches(pkg, var_names)
      pkg_name_match = check_pkg_name_matches(pkg)
      (var_name_match || pkg_name_match) && !@mw_cookbook_whitelist.include?(cookbookname)
    end
    pkg_1liner_res = find_1liner_resources(ast, type: :package).select do |pkg|
      pkg_name_match = check_pkg_name_matches(pkg)
      pkg_names = get_package_names(pkg)
      # If we do not find a package_name lets check for variables we are interested in
      var_name_match = false
      if pkg_names.empty?
        var_name_match = check_var_name_matches(pkg, var_names)
      end
      (var_name_match || pkg_name_match) && !@mw_cookbook_whitelist.include?(cookbookname)
    end
    yum_pkg_res = find_resources(ast, type: :yum_package).select do |pkg|
      var_name_match = check_var_name_matches(pkg, var_names)
      pkg_name_match = check_pkg_name_matches(pkg)
      (var_name_match || pkg_name_match) && !@mw_cookbook_whitelist.include?(cookbookname)
    end
    yum_1liner_res = find_1liner_resources(ast, type: :yum_package).select do |pkg|
      pkg_name_match = check_pkg_name_matches(pkg)
      pkg_names = get_package_names(pkg)
      # If we do not find a package_name lets check for variables we are interested in
      var_name_match = false
      if pkg_names.empty?
        var_name_match = check_var_name_matches(pkg, var_names)
      end
      (var_name_match || pkg_name_match) && !@mw_cookbook_whitelist.include?(cookbookname)
    end
    pkg_res.concat(pkg_1liner_res).concat(yum_pkg_res).concat(yum_1liner_res).map { |pkg| match(pkg) }
  end
end

rule 'BARC028', 'Only whitelisted cookbooks can depend on restricted cookbooks' do
  tags %w[barc unix windows]
  metadata do |ast, filename|
    deps = field(ast, 'depends')
    dep_violations = []
    deps.each do |dep|
      dep_name = dep.xpath('.//tstring_content/@value').map(&:text).first
      dep_violations << dep if @restricted_cookbook_whitelist.include?(dep_name) &&
                               !@restricted_cookbook_whitelist[dep_name].include?(cookbook_name(filename))
    end
    dep_violations
  end
end

rule 'BARC029', 'Unauthorised access to community cookbook' do
  tags %w[barc unix windows metadata]
  metadata do |ast, filename|
    violations = []
    ckbname = cookbook_name(filename)
    @blocked_cookbooks.map do |metadata_hash|
      field, value = metadata_hash.to_a.first
      validwrap = @cookbook_wraps[ckbname] || ''
      unless value == validwrap
        violations << field(ast, field).xpath("descendant::tstring_content[@value='#{value}']")
      end
    end
    violations.flatten
  end
end

rule 'BARC030', 'Cookbook depends on a deprecated cookbook' do
  tags %w[barc unix windows metadata]
  metadata do |ast|
    deps = field(ast, 'depends')
    violations = []
    deps.each do |dep|
      dep_name = dep.xpath('.//tstring_content/@value').map(&:text).first
      violations << dep if @deprecated_cookbooks.keys.include?(dep_name)
    end
    violations
  end
end

# Controlled Packages
# An adoption of BARC027 for general package restrictions
rule 'BARC031', 'Cookbook uses controlled packages' do
  tags %w[barc unix]

  def get_var_names_from_prefix(ast, package_prefix)
    var_names = []
    var2var_names = []
    # look for variable assignments that match the "package_prefix"
    # Record the variable names for later use in var_names
    var_names.push(get_var_assignments(ast, package_prefix, 'starts'))
    var_names.flatten!

    # Lets check for var2var assignments
    var_names.each do |var_name|
      var2var_names.push(get_var2var_assignments(ast, var_name))
      var2var_names.flatten!
    end
    var_names += var2var_names
    var_names.uniq!
    var_names
  end

  def check_var_name_matches_prefix(resource, var_names)
    pkg_fragment = Nokogiri::XML.fragment(resource)
    # For each variable picked up lets look for resources that use it
    var_names.each do |var_name|
      var_xpath = "method_add_block/descendant::command[@value='command']/args_add_block/args_add/descendant::var_ref[@value='var_ref']/ident[@value=\"#{var_name}\"]|command/args_add_block/args_add/descendant::var_ref[@value='var_ref']/ident[@value=\"#{var_name}\"]"
      var_match = pkg_fragment.xpath(var_xpath)
      # If we get a match lets return true
      return true unless var_match.empty?
    end
    false
  end

  def check_pkg_name_matches_prefix(resource, package_prefix)
    pkg_names = get_package_names(resource)
    pkg_names.each do |pkg|
      return true if pkg.to_s.match("^#{package_prefix}.*")
    end
    false
  end

  recipe do |ast, filename|
    cookbookname = cookbook_name(filename)
    violations = []

    find_resources(ast, type: :package).select do |pkg|
      @controlled_packages.each do |pkg_name, pkg_values|
        var_names = get_var_names_from_prefix(ast, pkg_name)
        var_name_match = check_var_name_matches_prefix(pkg, var_names)
        pkg_name_match = check_pkg_name_matches_prefix(pkg, pkg_name)
        violations << pkg if (var_name_match || pkg_name_match) && !pkg_values['whitelist'].include?(cookbookname)
      end
    end

    find_1liner_resources(ast, type: :package).select do |pkg|
      @controlled_packages.each do |pkg_name, pkg_values|
        var_names = get_var_names_from_prefix(ast, pkg_name)
        pkg_name_match = check_pkg_name_matches_prefix(pkg, pkg_name)
        pkg_names = get_package_names(pkg)
        # If we do not find a package_name lets check for variables we are interested in
        var_name_match = false
        if pkg_names.empty?
          var_name_match = check_var_name_matches_prefix(pkg, var_names)
        end
        violations << pkg if (var_name_match || pkg_name_match) && !pkg_values['whitelist'].include?(cookbookname)
      end
    end

    find_resources(ast, type: :yum_package).select do |pkg|
      @controlled_packages.each do |pkg_name, pkg_values|
        var_names = get_var_names_from_prefix(ast, pkg_name)
        var_name_match = check_var_name_matches_prefix(pkg, var_names)
        pkg_name_match = check_pkg_name_matches_prefix(pkg, pkg_name)
        violations << pkg if (var_name_match || pkg_name_match) && !pkg_values['whitelist'].include?(cookbookname)
      end
    end

    find_1liner_resources(ast, type: :yum_package).select do |pkg|
      @controlled_packages.each do |pkg_name, pkg_values|
        var_names = get_var_names_from_prefix(ast, pkg_name)
        pkg_name_match = check_pkg_name_matches_prefix(pkg, pkg_name)
        pkg_names = get_package_names(pkg)
        # If we do not find a package_name lets check for variables we are interested in
        var_name_match = false
        if pkg_names.empty?
          var_name_match = check_var_name_matches_prefix(pkg, var_names)
        end
        violations << pkg if (var_name_match || pkg_name_match) && !pkg_values['whitelist'].include?(cookbookname)
      end
    end
    violations.flatten
  end
end

rule 'BARC032', 'Cookbook depends on a cookbook version flagged as no longer supported or incompatible' do
  tags %w[barc unix windows metadata]
  metadata do |ast|
    deps = field(ast, 'depends')
    violations = []
    deps.each do |dep|
      dep_map = dep.xpath('.//tstring_content/@value').map(&:text)
      next unless @cookbook_minimum_versions.keys.include?(dep_map.first)
      next if dep_map.length == 1 # no version pinning

      violations << dep unless Gem::Version.new(dep_map.last[/\d+\.\d+\.\d+/]) >= Gem::Version.new(@cookbook_minimum_versions[dep_map.first])
    end
    violations
  end
end

rule 'BARC033', 'Cookbook must depend on a cookbook with allowed pin only XXX' do
  tags %w[barc unix windows metadata]
  metadata do |ast|
    name = field(ast, 'name')
    ckbname = name.xpath('.//tstring_content/@value').map(&:text)
    deps = field(ast, 'depends')
    violations = []
    next unless @whitelist_cookbook_allowed_pins_only.include?(ckbname)

    deps.each do |dep|
      dep_map = dep.xpath('.//tstring_content/@value').map(&:text)
      next unless @cookbook_allowed_pins_only.keys.include?(dep_map.first)
      next if dep_map.length == 1 # no version pinning

      violations << dep unless @cookbook_allowed_pins_only[dep_map.first].any? { |pin| dep_map.last.start_with?(pin) }
    end
    violations
  end
end

rule 'BARC034', 'Restricted attributes check[Roles]' do
  tags %w[barc unix role]
  cookbook do |path|
    ckbname = cookbook_name(path.to_s)
    roles = Dir["#{path}/roles/*.json"]
    roles.collect do |role|
      lines = File.readlines(role)
      lines.collect.with_index do |line, _index|
        { filename: line } if @restricted_attributes.any? do |atr, cookbook|
          line.include?(atr) && !cookbook.include?(ckbname)
        end
      end.compact
    end
  end
end

rule 'BARC035', 'Restricted attributes check[Attributes|Recipes|Provider|Library]' do
  tags %w[barc unix role]
  recipe do |_ast, filename|
    next if filename.include?('metadata')

    ckbname = cookbook_name(filename)
    lines = File.readlines(filename)
    lines.collect.with_index do |line, _index|
      { filename: line } if @restricted_attributes.any? do |atr, cookbook|
        line.include?(atr) && !cookbook.include?(ckbname)
      end
    end.compact
  end
end

rule 'BARC036', 'Java version hard pined up DWB/ORAC required' do
  tags %w[barc unix java]
  recipe do |ast, filename|
    ckbname = cookbook_name(filename)
    res = Array(resource_attributes_by_type(ast)['b_iac_cc_java_package']).select do |java|
      java.include?('update_number')
    end
    next if res.empty?

    res.reject { |_java| @orac_java_hard_pined_up.include?(ckbname) }
  end
end
