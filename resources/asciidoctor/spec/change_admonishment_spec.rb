# frozen_string_literal: true

require 'change_admonition/extension'

RSpec.describe ChangeAdmonition do
  before(:each) do
    Asciidoctor::Extensions.register ChangeAdmonition
  end

  after(:each) do
    Asciidoctor::Extensions.unregister_all
  end

  [
      %w[added added note],
      %w[coming changed note],
      %w[deprecated deleted warning],
  ].each do |(name, revisionflag, tag)|
    it "#{name}'s block version creates a #{tag}" do
      actual = convert <<~ASCIIDOC
        == Example
        #{name}::[some_version]
      ASCIIDOC
      expected = <<~DOCBOOK
        <chapter id="_example">
        <title>Example</title>
        <#{tag} revisionflag="#{revisionflag}" revision="some_version">
        <simpara></simpara>
        </#{tag}>
        </chapter>
      DOCBOOK
      expect(actual).to eq(expected.strip)
    end

    it "#{name}'s block version supports asciidoc in the passtext" do
      actual = convert <<~ASCIIDOC
        == Example
        #{name}::[some_version,See <<some-reference>>]
        [[some-reference]]
        === Some Reference
      ASCIIDOC
      expected = <<~DOCBOOK
        <chapter id="_example">
        <title>Example</title>
        <#{tag} revisionflag="#{revisionflag}" revision="some_version">
        <simpara>See <xref linkend="some-reference"/></simpara>
        </#{tag}>
        <section id="some-reference">
        <title>Some Reference</title>

        </section>
        </chapter>
      DOCBOOK
      expect(actual).to eq(expected.strip)
    end

    it "#{name}'s block version is not invoked without the ::" do
      actual = convert <<~ASCIIDOC
        == Example
        #{name}[some_version]
      ASCIIDOC
      expected = <<~DOCBOOK
        <chapter id="_example">
        <title>Example</title>
        <simpara>#{name}[some_version]</simpara>
        </chapter>
      DOCBOOK
      expect(actual).to eq(expected.strip)
    end

    it "#{name}'s inline version creates a phrase" do
      actual = convert <<~ASCIIDOC
        == Example
        words #{name}:[some_version]
      ASCIIDOC
      expected = <<~DOCBOOK
        <chapter id="_example">
        <title>Example</title>
        <simpara>words <phrase revisionflag="#{revisionflag}" revision="some_version"/>
        </simpara>
        </chapter>
      DOCBOOK
      expect(actual).to eq(expected.strip)
    end

    it "#{name}'s inline version creates a phrase with extra text if provided" do
      actual = convert <<~ASCIIDOC
        == Example
        words #{name}:[some_version, more words]
      ASCIIDOC
      expected = <<~DOCBOOK
        <chapter id="_example">
        <title>Example</title>
        <simpara>words <phrase revisionflag="#{revisionflag}" revision="some_version">
          more words
        </phrase>
        </simpara>
        </chapter>
      DOCBOOK
      expect(actual).to eq(expected.strip)
    end

    it "#{name}'s inline version is not invoked without the :" do
      actual = convert <<~ASCIIDOC
        == Example
        words #{name}[some_version]
      ASCIIDOC
      expected = <<~DOCBOOK
        <chapter id="_example">
        <title>Example</title>
        <simpara>words #{name}[some_version]</simpara>
        </chapter>
      DOCBOOK
      expect(actual).to eq(expected.strip)
    end
  end
end
