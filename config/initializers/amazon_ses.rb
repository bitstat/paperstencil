require 'aws/ses'

_aws_ses_init_values = {}
_aws_ses_init_values[:access_key_id] = PaperstencilConfig[:aws_ses][:access_key_id]
_aws_ses_init_values[:secret_access_key] = PaperstencilConfig[:aws_ses][:secret_access_key]
_aws_ses_init_values[:proxy_server] = ENV['http_proxy'] if ENV['http_proxy']

ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base, _aws_ses_init_values

