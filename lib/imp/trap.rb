# encoding: utf-8
module Imp

  module Trap

    FILE_LOCK = "/tmp/imp_#{::Process.ppid}.lock".freeze

    extend self

    def catch

      # Если работаем из консоли или запускаем rake-задачу,
      # игнориуем сигналы, завершающие работу демона и не блокируем процесс.
      return true if defined?(::IRB) || defined?(::Rake)

      begin

        return false if ::File.exist?(::Imp::Trap::FILE_LOCK)

        f = ::File.new(::Imp::Trap::FILE_LOCK, ::File::RDWR|::File::CREAT, 0400)
        return false if (f.flock(::File::LOCK_EX) === false)

        trap_signals

        return true

      rescue
        return false
      end

    end # catch

    private

    def exit_process

      begin
        ::Imp.stop_all
      ensure
        ::FileUtils.rm ::Imp::Trap::FILE_LOCK, :force => true
      end

    end # exit_process

    def trap_signals

      # Завершение работы при получении указанных сигналов
      ::Imp::EXIT_SIGNALS.each do |sig|
        trap(sig) { exit_process }
      end # each

      at_exit { exit_process }

    end # trap_signals

  end # Trap

end # Imp