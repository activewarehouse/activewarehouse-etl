require 'digest/md5'

module ETL #:nodoc:
  module Transform #:nodoc:
    # Transform which hashes the original value with a MD5 hash algorithm
    class Md5Transform < ETL::Transform::Transform
      # Transform the value with a MD5 digest algorithm.
      def transform(name, value, row)
        Digest::MD5.hexdigest(value)
      end
    end
  end
end
