#! /usr/bin/env ruby
#
# metrics-typeperf.rb
#
# DESCRIPTION:
#
# OUTPUT:
#  metric data
#
# PLATFORMS:
#   windows
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#
# NOTES:
#  Tested on Windows 2012RC2.
#
# LICENSE:
#    Inspired by the work of: Yohei Kawahara <inokara@gmail.com>
#    Original Repo: https://github.com/sensu-plugins/sensu-plugins-iis
#    Author: Martin Cozzi <martin@marana.in>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'socket'

class Typeperf < Sensu::Plugin::Metric::CLI::Graphite
  option :metric,
         description: 'Name of the typeperf metric to record',
         long: '--metric METRIC'

  option :scheme,
         description: 'Metric naming scheme, text to prepend to .$parent.$child',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}"

  option :occurences,
         long: '--occurences OCCURENCES',
         short: '-o occurences',
         default: 2

  def run
    io = IO.popen("typeperf -sc #{config[:occurences]} \"#{config[:metric]}\"")
    occurences = config[:occurences].to_i
    get_requests = io.readlines[occurences + 1].split(',')[1].delete('"').to_f

    output config[:scheme], get_requests
    ok
  end
end
