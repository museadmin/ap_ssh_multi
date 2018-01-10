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

  def test_action_pack_loads
    sm = StateMachine.new
    apm = ApMessageIo.new
    aps = ApSshMulti.new

    apm.export_action_pack(state_machine: sm)
    aps.export_action_pack(state_machine: sm)
    sm.execute

    wait_for_run_phase('RUNNING', sm, 10)
    write_message_file(sm.query_property('in_pending'), 'SYS_NORMAL_SHUTDOWN')
    wait_for_run_phase('SHUTDOWN', sm, 10)
  end

  # Wait for a change of run phase in the state machine.
  # Raise error if timeout.
  # @param phase [String] Name of phase to wait for
  # @param state_machine [StateMachine] An instance of a state machine
  # @param time_out [FixedNum] The time out period
  def wait_for_run_phase(phase, state_machine, time_out)
    EM.run do
      t = EM::Timer.new(time_out) do
        EM.stop
        return false
      end

      p = EM::PeriodicTimer.new(1) do
        if state_machine.query_run_phase_state == phase
          p.cancel
          t.cancel
          EM.stop
          return true
        end
      end
    end
  end

  # Drop a message into the queue with a shutdown flag
  def write_message_file(in_pending, flag)
    builder = MessageBuilder.new
    builder.sender = 'localhost'
    builder.action = flag
    builder.payload = '{ "test": "value" }'
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
