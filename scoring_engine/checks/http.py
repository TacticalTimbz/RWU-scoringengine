from scoring_engine.engine.basic_check import BasicCheck


class HTTPCheck(BasicCheck):
    required_properties = ['useragent', 'vhost', 'uri']
    CMD = 'curl {1}'

    def command_format(self, properties):
        host_header = 'Host: ' + properties['vhost']
        host_uri = self.host + ':' + str(self.port) + properties['uri']
        return (host_header, properties['useragent'], host_uri)
