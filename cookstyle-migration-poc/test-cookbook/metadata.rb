# Sample Cookbook - Demonstrates BARC rule violations
# This cookbook is intentionally written with violations to test the custom cops

name              'sample-app-cookbook'
maintainer        'DevOps Team'
maintainer_email  'devops@company.com'
license           'Proprietary'
description       'Sample application cookbook for testing Cookstyle BARC rules'
version           '1.0.0'
chef_version      '>= 17.0'

# Dependencies
depends 'apt'
depends 'yum'
