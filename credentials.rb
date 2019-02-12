
if ENV['EWS_ENDPOINT'].is_set?
	Endpoint = ENV['EWS_ENDPOINT']
else
	Endpoint = 'https://xxxxxxxx.xxx/ews/Exchange.asmx'

	if ENV['EWS_USER'].is_set?
	User = ENV['EWS_USER']
else
	User = 'xxx'

	if ENV['EWS_PASS'].is_set?
	Pass = ENV['EWS_PASS']
else
	Pass = 'xxx'

	if ENV['EWS_DOMAIN'].is_set?
	Domain = ENV['EWS_DOMAIN']
else
	Domain = 'xxx'
