require 'spec_helper'

RSpec.describe 'fixtures/google-analytics.xml' do
  let(:xml) { load_fixture('google-analytics.xml') }
  let(:doc_class) { described_class }
  let(:doc) { doc_class.from_xml(xml) }
  let(:root) { doc.root }
  let(:entries) { root.entries }
  let(:entry1) { entries.first }
  let(:entry2) { entries.last }
  let(:hash) { JSON.parse(json) }

  describe GoogleAnalyticsDocumentNotDescribed do
    let(:entries) { root.entry }
    let(:json) { load_fixture('google-analytics.not_described.json') }

    it 'document and root' do
      expect(doc).to be_a(GoogleAnalyticsDocumentNotDescribed)
      expect(doc.version).to eq "1.0"
      expect(doc.encoding).to be_nil
      expect(entries.size).to eq 2
      expect(root.environment).to be_proxied 'test'
      expect(root.environment).to has_default_namespace
      expect(root.totalResults[0]).to be_proxied '1'
      expect(root.totalResults[0]).to has_namespace(:openSearch)
      expect(root.startIndex[0]).to be_proxied '1'
      expect(root.startIndex[0]).to has_namespace(:openSearch)
      expect(root.itemsPerPage[0]).to be_proxied '1000'
      expect(root.itemsPerPage[0]).to has_namespace(:openSearch)
      expect(root).to has_default_namespace
      expect(root).to defines_namespace(nil).with_href('http://www.w3.org/2005/Atom')
      expect(root).to defines_namespace(:dxp).with_href('http://schemas.google.com/analytics/2009')
      expect(root).to defines_namespace(:gd).with_href('http://schemas.google.com/g/2005')
    end

    it 'entry 1' do
      expect(entry1.property[0]).to has_namespace(:dxp)
      expect(entry1.property[0].name).to be_proxied('ga:profileId').and has_default_namespace
      expect(entry1.property[0].value).to be_proxied('1174').and has_default_namespace

      expect(entry1.goal.size).to eq 1
      expect(entry1.goal[0]).to has_namespace(:ga)
      expect(entry1.goal[0].active).to be_proxied('true').and has_default_namespace
      expect(entry1.goal[0].name).to be_proxied('Completing Order').and has_default_namespace
      expect(entry1.goal[0].number).to be_proxied('1').and has_default_namespace
      expect(entry1.goal[0].value).to be_proxied('10.0').and has_default_namespace

      expect(entry1.goal[0].destination.size).to eq 1
      dest = entry1.goal[0].destination[0]
      expect(dest.caseSensitive).to be_proxied('false').and has_default_namespace
      expect(dest.expression).to be_proxied('/purchaseComplete.html').and has_default_namespace
      expect(dest.matchType).to be_proxied('regex').and has_default_namespace
      expect(dest.step1Required).to be_proxied('false').and has_default_namespace

      expect(dest.step.size).to eq 5
      expect(dest.step[0]).to has_namespace(:ga)
      expect(dest.step[0].name).to be_proxied('View Product Categories').and has_default_namespace
      expect(dest.step[0].number).to be_proxied('1').and has_default_namespace
      expect(dest.step[0].path).to \
        be_proxied('/Apps|Accessories|Fun|Kid\+s|Office|Wearables').and has_default_namespace

      expect(dest.step[2].name).to be_proxied 'View Shopping Cart'
      expect(dest.step[2].number).to be_proxied '3'
      expect(dest.step[2].path).to be_proxied '/shoppingcart.aspx'

      expect(dest.step[4].name).to be_proxied 'Place Order'
      expect(dest.step[4].number).to be_proxied '5'
      expect(dest.step[4].path).to be_proxied '/placeOrder.html'

      expect(entry1.link.size).to eq 2
      expect(entry1.link[0].rel).to be_proxied('self').and has_default_namespace
      expect(entry1.link[0].type).to be_proxied('application/atom+xml').and has_default_namespace
      expect(entry1.link[0].href).to \
        be_proxied('https://www.googleapis.com/analytics/v2.4/management/accounts/30481/webproperties/UA-30481-1/profiles/1174/goals/1')
          .and has_default_namespace
      expect { entry1.link[0].targetKind }.to raise_error NoMethodError

      expect(entry1.link[1].rel).to be_proxied('http://schemas.google.com/ga/2009#parent').and has_default_namespace
      expect(entry1.link[1].type).to be_proxied('application/atom+xml').and has_default_namespace
      expect(entry1.link[1].href).to be_proxied('https://www.googleapis.com/analytics/v2.4/management/accounts/30481/webproperties/UA-30481-1/profiles/1174').and has_default_namespace
      expect(entry1.link[1].targetKind).to be_proxied('analytics#profile').and has_namespace(:gd)
    end

    it 'entry 1 bare values' do
      expect(entry1.property[0].name!).to eq 'ga:profileId'
      expect(entry1.property[0].value!).to eq '1174'

      expect(entry1.goal[0].active!).to eq 'true'
      expect(entry1.goal[0].name!).to eq 'Completing Order'
      expect(entry1.goal[0].number!).to eq '1'
      expect(entry1.goal[0].value!).to eq '10.0'

      dest = entry1.goal[0].destination[0]
      expect(dest.caseSensitive!).to eq 'false'
      expect(dest.expression!).to eq '/purchaseComplete.html'
      expect(dest.matchType!).to eq 'regex'
      expect(dest.step1Required!).to eq 'false'

      expect(dest.step[0].name!).to eq('View Product Categories')
      expect(dest.step[0].number!).to eq('1')
      expect(dest.step[0].path!).to \
        eq('/Apps|Accessories|Fun|Kid\+s|Office|Wearables')

      expect(dest.step[2].name!).to eq 'View Shopping Cart'
      expect(dest.step[2].number!).to eq '3'
      expect(dest.step[2].path!).to eq '/shoppingcart.aspx'

      expect(dest.step[4].name!).to eq 'Place Order'
      expect(dest.step[4].number!).to eq '5'
      expect(dest.step[4].path!).to eq '/placeOrder.html'

      expect(entry1.link[0].rel!).to eq 'self'
      expect(entry1.link[0].type!).to eq 'application/atom+xml'
      expect(entry1.link[0].href!).to \
        eq 'https://www.googleapis.com/analytics/v2.4/management/accounts/30481/webproperties/UA-30481-1/profiles/1174/goals/1'
      expect { entry1.link[0].targetKind }.to raise_error NoMethodError

      expect(entry1.link[1].rel!).to eq 'http://schemas.google.com/ga/2009#parent'
      expect(entry1.link[1].type!).to eq 'application/atom+xml'
      expect(entry1.link[1].href!).to \
        eq 'https://www.googleapis.com/analytics/v2.4/management/accounts/30481/webproperties/UA-30481-1/profiles/1174'
      expect(entry1.link[1].targetKind!).to eq 'analytics#profile'
    end

    it 'entry 2' do
      expect(entry2.property[0]).to has_default_namespace
      expect(entry2.property[0].name).to be_proxied('ga:summaryId').and has_default_namespace
      expect(entry2.property[0].value).to be_proxied('234').and has_default_namespace

      expect(entry2.goal.size).to eq 1
      expect(entry2.goal[0]).to has_namespace(:ga)
      expect(entry2.goal[0].active).to be_proxied('false').and has_default_namespace
      expect(entry2.goal[0].name).to be_proxied('Completing Order').and has_default_namespace
      expect(entry2.goal[0].number).to be_proxied('2').and has_default_namespace
      expect(entry2.goal[0].value).to be_proxied('9.0').and has_default_namespace

      expect(entry2.goal[0].destination.size).to eq 1
      dest = entry2.goal[0].destination[0]
      expect(dest.caseSensitive).to be_proxied 'true'
      expect(dest.expression).to be_proxied '/purchaseComplete.html'
      expect(dest.matchType).to be_proxied 'regex'
      expect(dest.step1Required).to be_proxied 'true'

      expect(dest.step.size).to eq 3
      expect(dest.step[1]).to has_namespace(:ga)
      expect(dest.step[1].name).to be_proxied('View Shopping Cart').and has_default_namespace
      expect(dest.step[1].number).to be_proxied('5').and has_default_namespace
      expect(dest.step[1].path).to be_proxied('/shoppingcart.aspx').and has_default_namespace

      expect { entry2.link }.to raise_error NoMethodError
    end

    it 'export to xml' do
      expect(doc.to_xml.gsub(%{<?xml version="1.0"?>\n}, '')).to eq xml
    end

    it 'export to json' do
      expect(doc.to_json(pretty: true)).to eq json
    end

    context 'when drop_undescribed is enabled' do
      let(:doc_class) { Class.new(described_class) { on_export :drop_undescribed } }
      let(:json) { { 'feed' => '' } }

      it 'export to json should contain contain only described fields' do
        expect(doc.to_h).to match_array json
      end
    end
  end

  describe GoogleAnalyticsDocumentDescribed do
    let(:json) { load_fixture('google-analytics.described.json') }

    it 'document and root' do
      expect(doc).to be_a(GoogleAnalyticsDocumentDescribed)
      expect(root).to eq doc.stat
      expect(root).to has_default_namespace
      expect(root).to defines_namespace(nil).with_href('http://www.w3.org/2005/Atom')
      expect(root).to defines_namespace(:dxp).with_href('http://schemas.google.com/analytics/2009')
      expect(root).to defines_namespace(:gd).with_href('http://schemas.google.com/g/2005')

      expect(root.env).to be_proxied 'test'
      expect(root.env).to has_default_namespace
      expect { root.environment }.to raise_error NoMethodError

      expect(entries.size).to eq 2
      expect(root.result).to be_proxied 1
      expect(root.result).to has_namespace(:openSearch)
      expect { root.totalResults }.to raise_error NoMethodError
      expect(root.index).to be_proxied 1
      expect(root.index).to has_namespace(:openSearch)
      expect(root.per_page).to be_proxied 1000
      expect(root.per_page).to has_namespace(:openSearch)
    end

    it 'entry 1' do
      expect(entry1.property).to has_namespace(:dxp)
      expect(entry1.property.name).to be_proxied('ga:profileId').and has_default_namespace
      expect(entry1.property.value).to be_proxied(1174).and has_default_namespace

      expect(entry1.goal).to has_namespace(:ga)
      expect(entry1.goal.active).to be_proxied(true).and has_default_namespace
      expect(entry1.goal.name).to be_proxied('Completing Order').and has_default_namespace
      expect(entry1.goal.number).to be_proxied(1).and has_default_namespace
      expect(entry1.goal.value).to be_proxied(10.0).and has_default_namespace

      dest = entry1.goal.dest
      expect(dest.case).to be_proxied(false).and has_default_namespace
      expect { dest.caseSensitive }.to raise_error NoMethodError
      expect(dest.expression).to be_proxied('/purchaseComplete.html').and has_default_namespace
      expect(dest.matchType).to be_proxied('regex').and has_default_namespace
      expect(dest.step1_required).to be_proxied(false).and has_default_namespace

      expect(dest.steps.size).to eq 5
      expect(dest.steps[0]).to has_namespace(:ga)
      expect(dest.steps[0].name).to be_proxied('View Product Categories').and has_default_namespace
      expect(dest.steps[0].number).to be_proxied(1).and has_default_namespace
      expect(dest.steps[0].path).to \
        be_proxied('/Apps|Accessories|Fun|Kid\+s|Office|Wearables').and has_default_namespace

      expect(dest.steps[2].name).to be_proxied 'View Shopping Cart'
      expect(dest.steps[2].number).to be_proxied 3
      expect(dest.steps[2].path).to be_proxied '/shoppingcart.aspx'

      expect(dest.steps[4].name).to be_proxied 'Place Order'
      expect(dest.steps[4].number).to be_proxied 5
      expect(dest.steps[4].path).to be_proxied '/placeOrder.html'

      expect(entry1.links.size).to eq 2
      expect(entry1.links[0]).to has_default_namespace
      expect(entry1.links[0].rel).to be_proxied('self').and has_default_namespace
      expect(entry1.links[0].type).to be_proxied('application/atom+xml').and has_default_namespace
      expect(entry1.links[0].href).to \
        be_proxied('https://www.googleapis.com/analytics/v2.4/management/accounts/30481/webproperties/UA-30481-1/profiles/1174/goals/1')
          .and has_default_namespace
      expect(entry1.links[0].target).to be_proxied('').and has_namespace(:gd)
      expect { entry1.links[0].targetKind }.to raise_error NoMethodError

      expect(entry1.links[1].rel).to be_proxied('http://schemas.google.com/ga/2009#parent').and has_default_namespace
      expect(entry1.links[1].type).to be_proxied('application/atom+xml').and has_default_namespace
      expect(entry1.links[1].href).to be_proxied('https://www.googleapis.com/analytics/v2.4/management/accounts/30481/webproperties/UA-30481-1/profiles/1174').and has_default_namespace
      expect(entry1.links[1].target).to be_proxied('analytics#profile').and has_namespace(:gd)
    end

    it 'entry 1 bare values' do
      expect(entry1.property.name!).to eq 'ga:profileId'
      expect(entry1.property.value!).to eq 1174

      expect(entry1.goal.active!).to eq true
      expect(entry1.goal.name!).to eq 'Completing Order'
      expect(entry1.goal.number!).to eq 1
      expect(entry1.goal.value!).to eq 10.0

      dest = entry1.goal.dest
      expect(dest.case!).to eq false
      expect(dest.expression!).to eq '/purchaseComplete.html'
      expect(dest.matchType!).to eq 'regex'
      expect(dest.step1_required!).to eq false

      expect(dest.steps[0].name!).to eq('View Product Categories')
      expect(dest.steps[0].number!).to eq 1
      expect(dest.steps[0].path!).to \
        eq('/Apps|Accessories|Fun|Kid\+s|Office|Wearables')

      expect(dest.steps[2].name!).to eq 'View Shopping Cart'
      expect(dest.steps[2].number!).to eq 3
      expect(dest.steps[2].path!).to eq '/shoppingcart.aspx'

      expect(dest.steps[4].name!).to eq 'Place Order'
      expect(dest.steps[4].number!).to eq 5
      expect(dest.steps[4].path!).to eq '/placeOrder.html'

      expect(entry1.links[0].rel!).to eq 'self'
      expect(entry1.links[0].type!).to eq 'application/atom+xml'
      expect(entry1.links[0].href!).to \
        eq 'https://www.googleapis.com/analytics/v2.4/management/accounts/30481/webproperties/UA-30481-1/profiles/1174/goals/1'
      expect(entry1.links[0].target!).to eq ''

      expect(entry1.links[1].rel!).to eq 'http://schemas.google.com/ga/2009#parent'
      expect(entry1.links[1].type!).to eq 'application/atom+xml'
      expect(entry1.links[1].href!).to \
        eq 'https://www.googleapis.com/analytics/v2.4/management/accounts/30481/webproperties/UA-30481-1/profiles/1174'
      expect(entry1.links[1].target!).to eq 'analytics#profile'
    end

    it 'entry 2' do
      expect(entry2.property).to has_namespace(:dxp)
      expect(entry2.property.name).to be_proxied('').and has_default_namespace
      expect(entry2.property.value).to be_proxied(0).and has_default_namespace

      expect(entry2.goal).to has_namespace(:ga)
      expect(entry2.goal.active).to be_proxied(false).and has_default_namespace
      expect(entry2.goal.name).to be_proxied('Completing Order').and has_default_namespace
      expect(entry2.goal.number).to be_proxied(2).and has_default_namespace
      expect(entry2.goal.value).to be_proxied(9.0).and has_default_namespace

      dest = entry2.goal.dest
      expect(dest.case).to be_proxied true
      expect(dest.expression).to be_proxied '/purchaseComplete.html'
      expect(dest.matchType).to be_proxied 'regex'
      expect(dest.step1_required).to be_proxied true

      expect(dest.steps.size).to eq 3
      expect(dest.steps[1]).to has_namespace(:ga)
      expect(dest.steps[1].name).to be_proxied('View Shopping Cart').and has_default_namespace
      expect(dest.steps[1].number).to be_proxied(5).and has_default_namespace
      expect(dest.steps[1].path).to be_proxied('/shoppingcart.aspx').and has_default_namespace

      expect { entry2.link }.to raise_error NoMethodError
      expect(entry2.links.size).to eq 0
    end

    it 'export to xml' do
      expect(doc.to_xml).to eq xml
    end

    it 'export to json' do
      expect(doc.to_json(pretty: true)).to eq json
      expect(doc.to_h).to match_array hash
    end
  end
end
