module VagrantPlugins
  module DevCommands
    class Util
      # Jaro Winkler string distance
      #
      # Adapted from:
      # https://github.com/bbatsov/rubocop/blob/ec3123fc3454b080e1100e35480c6466d1240fff/lib/rubocop/string_util.rb
      class JaroWinkler
        BOOST_THRESHOLD          = 0.7
        MAX_COMMON_PREFIX_LENGTH = 4
        SCALING_FACTOR           = 0.1

        def initialize(left, right)
          @left  = left.to_s
          @right = right.to_s

          if @left.size < @right.size
            @shorter = @left
            @longer  = @right
          else
            @shorter = @right
            @longer  = @left
          end
        end

        def distance
          jaro_distance = compute_distance

          if jaro_distance >= BOOST_THRESHOLD
            jaro_distance += (
              limited_common_prefix_length.to_f *
              SCALING_FACTOR.to_f *
              (1.0 - jaro_distance)
            )
          end

          jaro_distance
        end

        private

        def common_prefix_length
          @shorter.size.times do |index|
            return index unless @shorter[index] == @longer[index]
          end

          @shorter.size
        end

        def compute_distance
          common_chars_a, common_chars_b = find_common_characters
          matched_count                  = common_chars_a.size

          return 0.0 if matched_count.zero?

          transposition_count = count_transpositions(common_chars_a,
                                                     common_chars_b)

          compute_non_zero_distance(matched_count.to_f, transposition_count)
        end

        def compute_non_zero_distance(matched_count, transposition_count)
          sum = (matched_count / @shorter.size.to_f) +
                (matched_count / @longer.size.to_f) +
                ((matched_count - transposition_count / 2) / matched_count)

          sum / 3.0
        end

        def count_transpositions(common_chars_a, common_chars_b)
          common_chars_a.size.times.count do |index|
            common_chars_a[index] != common_chars_b[index]
          end
        end

        # rubocop:disable Metrics/MethodLength
        def find_common_characters
          common_chars_of_shorter = Array.new(@shorter.size)
          common_chars_of_longer  = Array.new(@longer.size)

          @shorter.each_char.with_index do |shorter_char, shorter_index|
            matching_index_range(shorter_index).each do |longer_index|
              longer_char = @longer.chars[longer_index]

              next unless shorter_char == longer_char

              common_chars_of_shorter[shorter_index] = shorter_char
              common_chars_of_longer[longer_index]   = longer_char

              # Mark the matching character as already used
              @longer.chars[longer_index] = nil

              break
            end
          end

          [common_chars_of_shorter, common_chars_of_longer].map(&:compact)
        end
        # rubocop:enable Metrics/MethodLength

        def limited_common_prefix_length
          length = common_prefix_length

          if length > MAX_COMMON_PREFIX_LENGTH
            MAX_COMMON_PREFIX_LENGTH
          else
            length
          end
        end

        def matching_index_range(origin)
          min = origin - matching_window
          min = 0 if min < 0

          max = origin + matching_window

          min..max
        end

        def matching_window
          @matching_window ||= (@longer.size / 2).to_i - 1
        end
      end
    end
  end
end
