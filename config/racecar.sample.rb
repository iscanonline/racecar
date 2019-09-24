require File.dirname(__FILE__) + '/../examples/cat_consumer'

Racecar.configure do |config|
  config.routes = "<< insert your routes >>"
  config.sasl_plain_username = "<< insert your username >>"
  config.sasl_plain_password = "<< insert your password >>"

  # How to convert:
  # cd msp-eventbus-client\src\main\resources
  # keytool -importkeystore -srckeystore truststore.jks -destkeystore truststore.p12 -deststoretype pkcs12
  # openssl pkcs12 -in truststore.p12 -out kafka.pem
  config.ssl_ca_cert_file_path = File.dirname(__FILE__) + "/kafka.pem"
end