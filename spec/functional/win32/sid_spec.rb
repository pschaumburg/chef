#
# Author:: Dan Bjorge (<dbjorge@gmail.com>)
# Copyright:: Copyright (c) 2015 Dan Bjorge
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'
if Chef::Platform.windows?
  require 'chef/win32/security'
end

describe 'Chef::ReservedNames::Win32::SID', :windows_only do
  SID ||= Chef::ReservedNames::Win32::Security::SID

  it 'should resolve default_security_object_group as the current user' do
    expect(SID.default_security_object_group).to eq(SID.current_user)
  end

  context 'running as an elevated administrator user' do
    it 'should resolve default_security_object_owner as the Administrators group' do
      expect(SID.default_security_object_owner).to eq(SID.Administrators)
    end
  end

  context 'running as a non-elevated administrator user' do
    it 'should resolve default_security_object_owner as the current user' do
      skip 'requires user support in mixlib-shellout, see security_spec.rb'
      expect(SID.default_security_object_owner).to eq(SID.Administrators)
    end
  end

  context 'running as a non-elevated, non-administrator user' do
    it 'should resolve default_security_object_owner as the current user' do
      skip 'requires user support in mixlib-shellout, see security_spec.rb'
      expect(SID.default_security_object_owner).to eq(SID.current_user)
    end
  end
end
