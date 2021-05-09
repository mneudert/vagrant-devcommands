# frozen_string_literal: true

shared_context 'commandfile_cwd' do
  def cwd(dir)
    @initial_dir = Dir.pwd

    Dir.chdir(File.join(File.dirname(__FILE__), '..', dir))
  end

  def cwd_env
    Vagrant::Environment.new(
      cwd: Dir.pwd,
      ui_class: Helpers::UI::Tangible
    )
  end

  after do
    Dir.chdir(@initial_dir)
  end
end
