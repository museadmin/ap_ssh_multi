# frozen_string_literal: true

require 'test_helper'
require 'ap_message_io'
require 'ap_message_io/helpers/message_builder'
require 'eventmachine'

# Unit tests for the ssh multi action pack
class ApSshMultiTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ApSshMulti::VERSION
  end

  # Test the loading of our actions
  def test_action_pack_loads
    sm = StateMachine.new
    ApMessageIo.new(state_machine: sm)
    ApSshMulti.new(state_machine: sm)
    sm.execute
    assert(wait_for_run_phase('RUNNING', sm, 10))
    write_message_file(sm.query_property('in_pending'), 'SYS_NORMAL_SHUTDOWN')
    assert(wait_for_run_phase('SHUTDOWN', sm, 10))
  end

  # Test that the hosts data is loaded
  def test_host_data_load
    sm = StateMachine.new
    ApMessageIo.new(state_machine: sm)
    ApSshMulti.new(state_machine: sm)
    sm.execute

    assert(wait_for_run_phase('RUNNING', sm, 10))
    # Drop msg into q to load the host data
    write_message_load_hosts(sm)
    assert(wait_for_status('HOSTS_LOADED', sm, 10))
    write_message_file(sm.query_property('in_pending'), 'SYS_NORMAL_SHUTDOWN')
    assert(wait_for_run_phase('SHUTDOWN', sm, 10))
  end

  # Write an message for load hosts action
  def write_message_load_hosts(sm)
    host = { hostname: 'localhost' }
    host[:short_name] = 'localhost'
    host[:ip_address] = '127.0.0.1'
    host[:host_group] = 'test'
    payload = [host].to_json.to_s

    write_message_file(sm.query_property('in_pending'),
                       'ACTION_LOAD_HOSTS',
                       payload)
  end

  # Wait for a change of state for a specific state flag
  # # Raise error if timeout.
  # @param state [String] Name of state to wait for
  # @param state_machine [StateMachine] An instance of a state machine
  # @param time_out [FixedNum] The time out period
  def wait_for_status(state, state_machine, time_out)
    EM.run do
      EM::Timer.new(time_out) do
        EM.stop
        return false
      end

      EM::PeriodicTimer.new(1) do
        if state_machine.query_status(state) == 1
          EM.stop
          return true
        end
      end
    end
  end

  # Wait for a change of run phase in the state machine.
  # Raise error if timeout.
  # @param phase [String] Name of phase to wait for
  # @param state_machine [StateMachine] An instance of a state machine
  # @param time_out [FixedNum] The time out period
  def wait_for_run_phase(phase, state_machine, time_out)
    EM.run do
      EM::Timer.new(time_out) do
        EM.stop
        return false
      end

      EM::PeriodicTimer.new(1) do
        if state_machine.query_run_phase_state == phase
          EM.stop
          return true
        end
      end
    end
  end

  # Drop a message into the queue with a shutdown flag
  def write_message_file(in_pending, flag, payload = '{ "test": "value" }')
    builder = MessageBuilder.new
    builder.sender = 'localhost'
    builder.action = flag
    builder.payload = payload.to_s
    builder.direction = 'in'
    js = builder.build

    File.open("#{in_pending}/#{builder.id}", 'w') do |f|
      f.write(js)
    end

    File.open("#{in_pending}/#{builder.id}.flag", 'w') do |f|
      f.write('')
    end
  end
end
