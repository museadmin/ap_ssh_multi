# frozen_string_literal: true

require 'state/actions/parent_action'
require 'fileutils'

# Initialise the SSH Multi Action Pack
class ActionInitialiseSshMulti < ParentAction
  # Instantiate the action, args hash contains:
  # run_mode [Symbol] Either NORMAL or RECOVER,
  # logger [Symbol] The logger object for logging.
  # @param args [Hash] Required parameters for the action
  def initialize(args, flag)
    @flag = flag
    if args[:run_mode] == 'NORMAL'
      @phase = 'STARTUP'
      @activation = 'ACT'
      @payload = 'NULL'
    else
      recover_action(self)
    end
    super(args[:logger])
  end

  # Do the work for this action
  def execute
    return unless active
    create_hosts_table
    validate_hosts_table
    update_state('INIT_SSH_MULTI', 1)
    deactivate(@flag)
  end

  private

  # States for this action
  def states
    [
      ['0', 'INIT_SSH_MULTI', 'SSH Multi action pack is initialised']
    ]
  end

  # Create the hosts table in the DB if it hasn't been
  # created by another action pack.
  def create_hosts_table
    execute_sql_statement("CREATE TABLE IF NOT EXISTS hosts (\n" \
      "   hostname CHAR PRIMARY KEY, -- Hostname of server \n" \
      "   short_name CHAR NOT NULL,  -- Short version of hostname \n" \
      "   ip_address CHAR NOT NULL,  -- IP address of server \n" \
      "   host_group CHAR NOT NULL   -- User defined host group \n" \
      ");".strip)
  end

  # If hosts table exists already, check that required fields are present
  # This is not really a great check as someone might set a constraint
  # on an unknown field in the 3rd party hosts table found...
  def validate_hosts_table
    cols = { hostname: false,
             short_name: false,
             ip_address: false,
             host_group: false }
    execute_sql_query('PRAGMA table_info(\'hosts\');').each do |row|
      cols.each_key do |k|
        cols[k] = true if k.to_s == row[1]
      end
    end
    raise 'Invalid hosts table' if cols.value?(false)
  end
end