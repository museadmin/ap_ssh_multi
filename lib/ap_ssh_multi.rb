require 'ap_ssh_multi/version'
require 'state_machine'

# Modules can be added to state machine and methods called
# from messenger gem using .include_module method
class ApSshMulti
  # Relative path to our actions
  ACTIONS_DIR = '/lib/ap_ssh_multi/actions'.freeze

  def initialize(**args)
    export_action_pack(args) unless args.empty?
  end

  # Export the actions from this pack into a state machine
  def export_action_pack(args)
    root = File.expand_path('../..', __FILE__)
    path = root + ACTIONS_DIR
    path = root + '/' + args[:dir] unless args[:dir].nil?
    args[:state_machine].import_action_pack(path)
  end
end

# Module for unit test
module TestModule
  # Test method to prove export of module to state machine
  def test_method
    'Test String'
  end
end