# -*- coding: utf-8 -*-
#
# Copyright (C) 2012  Kouhei Sutou <kou@clear-code.com>
#
# License: Ruby's or LGPL
#
# This library is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "fileutils"
require "tmpdir"
require "tempfile"
require "time"

unless String.method_defined?(:encode)
  require "iconv"
end

require "gettext"

module GetTextTestUtils
  module_function
  def fixture_path(*components)
    File.join(File.dirname(__FILE__), "fixtures", *components)
  end

  def locale_path
    File.join(File.dirname(__FILE__), "locale")
  end

  def setup_tmpdir
    @tmpdir = Dir.mktmpdir
  end

  def teardown_tmpdir
    FileUtils.rm_rf(@tmpdir, :secure => true) if @tmpdir
  end

  def need_encoding
    unless defined?(Encoding)
      omit("This test needs encoding.")
    end
  end

  def set_encoding(string, encoding)
    return unless string.respond_to?(:force_encoding)
    string.force_encoding(encoding)
  end

  def encode(string, encoding)
    if string.respond_to?(:encode)
      string.encode(encoding)
    else
      Iconv.iconv(encoding, "UTF-8", string).join("")
    end
  end
end
