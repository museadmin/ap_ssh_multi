require 'state/actions/parent_action'
require 'fileutils'

# Initialise the SSH Multi Action Pack
class ActionLoadHosts < ParentAction

  attr_reader :flag

  # Instantiate the action, args hash contains:
  # run_mode [Symbol] Either NORMAL or RECOVER,
  # logger [Symbol] The logger object for logging.
  # @param args [Hash] Required parameters for the action
  def initialize(args, flag)
    @flag = flag
    if args[:run_mode] == 'NORMAL'
      @phase = 'RUNNING'
      @activation = 'SKIP'
      @payload = 'NULL'
    else
      recover_action(self)
    end
    super(args[:logger])
  end

  # Do the work for this action
  def execute
    return unless active
    load_host_data
    update_state('HOSTS_LOADED', 1)
    deactivate(@flag)
  end

  private

  # States for this action
  def states
    [
      ['0', 'HOSTS_LOADED', 'Hosts table has been populated with host data']
    ]
  end

  # Take the host data from our payload and write it
  # into the db
  def load_host_data
    JSON.parse(this_payload(@flag)).each do |h|
      execute_sql_statement(
        "INSERT INTO hosts \n" \
        "(hostname, short_name, ip_address, host_group) \n" \
        "values \n" \
        "('#{h['hostname']}', '#{h['short_name']}', " \
        "'#{h['ip_address']}', '#{h['host_group']}');"
      )
    end
  end
end