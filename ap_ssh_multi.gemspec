
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ap_ssh_multi/version'

Gem::Specification.new do |spec|
  spec.name          = 'ap_ssh_multi'
  spec.version       = ApSshMulti::VERSION
  spec.authors       = ['Bradley Atkins']
  spec.email         = ['bradley.atkins@bjss.com']

  spec.summary       = 'An action pack for the state-machine to handle
                        ssh-multiplexing'
  spec.description   = 'An action pack to implement ssh-multiplexing
                        for a state-machine'
  spec.homepage      = 'TODO: Put your gems website or public repo URL here.'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either
  # set the allowed_push_host
  # to allow pushing to a single host or delete this section to
  # allow pushing to any host.

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'TODO: Set to http://mygemserver.com'
  else
    raise 'RubyGems 2.0 or newer is required to protect against
      public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'ap_message_io', '~> 0.1.0'
  spec.add_runtime_dependency 'bundler', '~> 1.16'
  spec.add_runtime_dependency 'minitest', '~> 5.10.1'
  spec.add_runtime_dependency 'net-ssh-multi', '~> 1.2', '>= 1.2.1'
  spec.add_runtime_dependency 'rake', '~> 0'
  spec.add_runtime_dependency 'state-machine', '~> 0.1.4'
  spec.add_runtime_dependency 'yard', '~> 0.9.12'
end
