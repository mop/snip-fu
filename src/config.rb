require 'yaml'
module SnipFu
  # This class is responsible for loading the config from the config.yml-file
  # in the snip-fu directory of vim. The yml-config file should contain a
  # start_tag and end_tag key, which might be one of the following signs:
  # $[]${}$<>$%%
  class Config
    class << self
      # Loads the config from the file
      def load
        @@config = create_config(YAML.load_file(config_dir)) \
          rescue create_config({})
        escape_for_regexps
      end

      # Returns the given key from the config-hash.
      #
      # ==== Parameters
      # key<Symbol>::
      #   The config-key which should be returned.
      #
      # ==== Options (key)
      # :start_tag::
      #   The start tag (e.g. ${)
      # :end_tag::
      #   The end tag (e.g. })
      # :regex_start_tag::
      #   The start tag escaped for use in regular expressions
      # :regex_end_tag::
      #   The end tag escaped for use in regular expressions
      #
      # ==== Returns
      # String::
      #   The config-element is returned (a String most of the time)
      def [](key)
        @@config ||= nil
        create_default_config unless @@config
      	@@config[key]
      end

      # Overwrites the given config-key with the given value. It updates the
      # regexp-keys after the assignment, so you might only assign :start_tag
      # and :end_tag!
      #
      # ==== Paramerters
      # key<Symbol>::
      #   The config-key which should be overwritten
      # val<String>::
      #   The new value of the config-key
      #
      # ==== Options (key)
      # :start_tag::
      #   The start tag (e.g. ${)
      # :end_tag::
      #   The end tag (e.g. })
      #
      # ==== Returns
      # String::
      #   val is returned.
      def []=(key, val)
        @@config ||= {}
        @@config[key] = val
        escape_for_regexps
        val
      end

      private
      def create_default_config
        @@config = create_config({})
        escape_for_regexps
      end

      def config_dir
        ENV['HOME'] + '/.vim/snip-fu/config.yml'
      end

      def create_config(config)
      	start_tag = config['start_tag'] || '${'
      	end_tag   = config['end_tag']   || '}'
        if valid_tags?(start_tag, end_tag)
          { :start_tag => start_tag, :end_tag => end_tag }
        else
          { :start_tag => '${', :end_tag => '}' }
        end
      end

      def escape_for_regexps
        @@config[:regex_start_tag] = Regexp.escape(@@config[:start_tag])
        @@config[:regex_end_tag]   = Regexp.escape(@@config[:end_tag])
      end

      def valid_tags
      	@@valid_tags = [ '$[', ']', '${', '}', '$<', '>', '$%', '%' ]
      end

      def valid_tags?(s, e)
      	valid_tags.include?(s) && valid_tags.include?(e)
      end
    end
  end
end
