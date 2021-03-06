require 'spec_helper'

describe 'reviewboard::site', :type => :define do
  let(:title) { '/opt/reviewboard/site' }

  let :pre_condition do
    "package {'python-pip': ensure => present, }"
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "define without any parameters on #{osfamily}" do
        let(:params) {{
            :dbpass     => 'foo',
            :adminpass  => 'bar',
            :adminemail => 'email@fqdn.example.com'
        }}
	let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it { should create_class('reviewboard') } # include

        it { should contain_reviewboard__provider__db('/opt/reviewboard/site').with({
                                                                         :dbuser => 'reviewboard',
                                                                         :dbpass => 'foo',
                                                                         :dbname => 'reviewboard',
                                                                         :dbhost => 'localhost'
                                                                         })
        }

        it { should contain_reviewboard__site__install('/opt/reviewboard/site').with({
                                                                          :vhost      => 'fqdn.example.com',
                                                                          :location   => '/',
                                                                          :dbtype     => 'postgresql',
                                                                          :dbname     => 'reviewboard',
                                                                          :dbhost     => 'localhost',
                                                                          :dbuser     => 'reviewboard',
                                                                          :dbpass     => 'foo',
                                                                          :admin      => 'admin',
                                                                          :adminpass  => 'bar',
                                                                          :adminemail => 'email@fqdn.example.com',
                                                                          :cache      => 'memcached',
                                                                          :cacheinfo  => 'localhost:11211',
                                                                          :require    => 'Reviewboard::Provider::Db[/opt/reviewboard/site]',
                                                                          :venv_path  => '/opt/reviewboard',
                                                                          })
        }

        it { should contain_reviewboard__provider__web('/opt/reviewboard/site').with({
                                                                          :vhost            => 'fqdn.example.com',
                                                                          :location         => '/',
                                                                          :webuser          => nil,
                                                                          :venv_path        => '/opt/reviewboard',
                                                                          :venv_python      => '/usr/bin/python2.7',
                                                                          :base_venv        => '/opt/empty_base_venv',
                                                                          :mod_wsgi_package => nil,
                                                                          :mod_wsgi_so_name => nil,
                                                                          :require          => 'Reviewboard::Site::Install[/opt/reviewboard/site]',
                                                                          })
        }
      end
      describe "define with specified webuser on #{osfamily}" do
        let(:params) {{
            :dbpass     => 'foo',
            :adminpass  => 'bar',
        }}
	let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let(:pre_condition) { "class {'reviewboard': webuser => 'apache' }" }

        it { should create_class('reviewboard') } # include

        it { should contain_reviewboard__provider__web('/opt/reviewboard/site').with({
                                                                          :vhost       => 'fqdn.example.com',
                                                                          :location    => '/',
                                                                          :webuser     => 'apache',
                                                                          :venv_path   => '/opt/reviewboard',
                                                                          :venv_python => '/usr/bin/python2.7',
                                                                          :base_venv   => '/opt/empty_base_venv',
                                                                          :require     => 'Reviewboard::Site::Install[/opt/reviewboard/site]',
                                                                          })
        }

      end
      describe "define with specified python and mod_wsgi on #{osfamily}" do
        let(:params) {{
            :dbpass     => 'foo',
            :adminpass  => 'bar',
        }}
	let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let :pre_condition do
          <<-eos
          class {'reviewboard':
            webuser               => 'apache',
            venv_python           => '/usr/bin/python3.3',
            virtualenv_script     => '/usr/bin/virtualenv3.3',
            mod_wsgi_package_name => 'python33-mod_wsgi',
            mod_wsgi_so_name      => 'python33-mod_wsgi',
          }
          eos
        end

        it { should create_class('reviewboard') } # include

        it { should contain_reviewboard__provider__web('/opt/reviewboard/site').with({
                                                                          :vhost                 => 'fqdn.example.com',
                                                                          :location              => '/',
                                                                          :webuser               => 'apache',
                                                                          :venv_path             => '/opt/reviewboard',
                                                                          :base_venv             => '/opt/empty_base_venv',
                                                                          :venv_python           => '/usr/bin/python3.3',
                                                                          :mod_wsgi_package_name => 'python33-mod_wsgi',
                                                                          :mod_wsgi_so_name      => 'python33-mod_wsgi',
                                                                          :require               => 'Reviewboard::Site::Install[/opt/reviewboard/site]',
                                                                          })
        }

      end
      describe 'using system python' do
        let(:params) {{
                        :dbpass     => 'foo',
                        :adminpass  => 'bar',
                        :adminemail => 'email@fqdn.example.com',
                      }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let(:pre_condition) { "class {'reviewboard': venv_python => '/usr/bin/python'}" }

        it { should create_class('reviewboard') } # include

        it { should contain_reviewboard__provider__db('/opt/reviewboard/site').with({
                                                                                      :dbuser => 'reviewboard',
                                                                                      :dbpass => 'foo',
                                                                                      :dbname => 'reviewboard',
                                                                                      :dbhost => 'localhost'
                                                                                    })
        }

        it { should contain_reviewboard__site__install('/opt/reviewboard/site').with({
                                                                                       :vhost      => 'fqdn.example.com',
                                                                                       :location   => '/',
                                                                                       :dbtype     => 'postgresql',
                                                                                       :dbname     => 'reviewboard',
                                                                                       :dbhost     => 'localhost',
                                                                                       :dbuser     => 'reviewboard',
                                                                                       :dbpass     => 'foo',
                                                                                       :admin      => 'admin',
                                                                                       :adminpass  => 'bar',
                                                                                       :adminemail => 'email@fqdn.example.com',
                                                                                       :cache      => 'memcached',
                                                                                       :cacheinfo  => 'localhost:11211',
                                                                                       :require    => 'Reviewboard::Provider::Db[/opt/reviewboard/site]',
                                                                                       :venv_path  => '/opt/reviewboard',
                                                                                     })
        }

        it { should contain_reviewboard__provider__web('/opt/reviewboard/site').with({
                                                                                       :vhost            => 'fqdn.example.com',
                                                                                       :location         => '/',
                                                                                       :webuser          => nil,
                                                                                       :venv_path        => '/opt/reviewboard',
                                                                                       :venv_python      => '/usr/bin/python',
                                                                                       :base_venv        => '/opt/empty_base_venv',
                                                                                       :mod_wsgi_package => nil,
                                                                                       :mod_wsgi_so_name => nil,
                                                                                       :require          => 'Reviewboard::Site::Install[/opt/reviewboard/site]',
                                                                                     })
        }
      end
    end
  end

  context 'input validation' do
    let(:facts) { SpecHelperFacts.new().facts }

    describe 'dbpass undefined should fail' do
      let(:params) {{
        :dbpass => Undef.new
      }}

      it do
        expect {
          should contain_reviewboard__provider__web('/opt/reviewboard/site')
        }.to raise_error(Puppet::Error, /Postgres DB password not set/)
      end
    end

    describe 'adminpass undefined should fail' do
      let(:params) {{
        :dbpass    => 'foo',
        :adminpass => Undef.new
      }}

      it do
        expect {
          should contain_reviewboard__provider__web('/opt/reviewboard/site')
        }.to raise_error(Puppet::Error, /Admin password not set/)
      end
    end

    describe 'adminemail or web user must be set' do
      let(:params) {{
        :dbpass    => 'foo',
        :adminpass => 'foo'
      }}

      it do
        expect {
          should contain_reviewboard__provider__web('/opt/reviewboard/site')
        }.to raise_error(Puppet::Error, /webuser must be explicitly set if adminemail is not/)
      end
    end

    describe 'name not an absolute path' do
      let(:title) { 'sitename' }
      let(:params) {{
        :dbpass    => 'foo',
        :adminpass => 'foo'
      }}

      it do
        expect {
          should contain_reviewboard__provider__web('sitename')
        }.to raise_error(Puppet::Error, /"sitename" is not an absolute path/)
      end
    end

    describe 'non-/ location with puppetlabs/apache web provider should fail' do
      let(:params) {{
        :dbpass     => 'foo',
        :adminpass  => 'foo',
        :adminemail => 'foo@example.com',
        :location   => '/foo/bar/baz'
      }}

      it do
        expect {
          should contain_reviewboard__provider__web('/opt/reviewboard/site')
        }.to raise_error(Puppet::Error, /Due to a bug in puppet allowing only hashes keyed by string literals/)
      end
    end
    describe "location /foo should be normalized to /foo/" do
      let(:params) {{
          :dbpass     => 'foo',
          :adminpass  => 'bar',
          :adminemail => 'email@fqdn.example.com',
          :location   => '/foo'
      }}
      let(:pre_condition) { "class {'reviewboard': webprovider => 'none'}" }

      it { should contain_reviewboard__site__install('/opt/reviewboard/site').with({
                                                                        :location   => '/foo/',
                                                                        })
      }

      it { should contain_reviewboard__provider__web('/opt/reviewboard/site').with({
                                                                        :location    => '/foo',
                                                                        :venv_path   => '/opt/reviewboard',
                                                                        :venv_python => '/usr/bin/python2.7',
                                                                        :base_venv   => '/opt/empty_base_venv',
                                                                        })
      }

    end
  end
end
