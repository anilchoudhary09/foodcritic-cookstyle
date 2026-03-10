# frozen_string_literal: true

name              'compliant-cookbook'
maintainer        'DevOps Team'
maintainer_email  'devops@company.com'
license           'Apache-2.0'
description       'A fully compliant Chef cookbook following all Barclays security policies'
version           '1.0.0'
chef_version      '>= 17.0'

supports 'ubuntu'
supports 'centos'
supports 'redhat'

depends 'apt'
