require 'socket'

module Celluloid
  module IO
    # UNIXServer with combined blocking and evented support
    class UNIXServer
      extend Forwardable
      def_delegators :@server, :listen, :sysaccept, :close, :closed?

      def self.open(socket_path)
        self.new(socket_path)
      end

      def initialize(socket_path)
        @server = ::UNIXServer.new(socket_path)
      end

      def accept
        Celluloid::IO.wait_readable(@server)
        accept_nonblock
      end

      def accept_nonblock
        Celluloid::IO::UNIXSocket.new(@server.accept_nonblock)
      end

      def to_io
        @server
      end

      # Are we inside a Celluloid ::IO actor?
      def evented?
        actor = Thread.current[:celluloid_actor]
        actor && actor.mailbox.is_a?(Celluloid::IO::Mailbox)
      end
    end
  end
end
