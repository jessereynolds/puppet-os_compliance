require 'spec_helper'

describe 'os_compliance::rules::account_policies::password_policies::password_history' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
