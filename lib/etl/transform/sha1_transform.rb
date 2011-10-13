require 'digest/sha1'

module ETL #:nodoc:
  class Transform #:nodoc:
    # Transform which hashes the original value with a SHA-1 hash algorithm
    class Sha1Transform < ETL::Transform
      # Transform the value with a SHA1 digest algorithm.
      def transform(name, value, row)
        Digest::SHA1.hexdigest(value)
      end
    end
  end
end
