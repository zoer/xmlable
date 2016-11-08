class GoogleAnalyticsDocumentNotDescribed
  include [XMLable, XMLable::Document].sample

  document
end

class GoogleAnalyticsDocumentDescribed
  include [XMLable, XMLable::Document].sample

  document

  nokogiri_export :no_declaration

  root :stat, tag: 'feed' do
    namespace :dxp, 'http://schemas.google.com/analytics/2009'
    namespace :ga, 'http://schemas.google.com/ga/2009'
    namespace :openSearch, 'http://a9.com/-/spec/opensearchrss/1.0/'
    namespace :gd, 'http://schemas.google.com/g/2005'
    namespace nil, 'http://www.w3.org/2005/Atom'

    attribute :env, tag: 'environment'

    element :result, :int, tag: 'totalResults', namespace: 'openSearch'
    element :index, :int, tag: 'startIndex', namespace: 'openSearch'
    element :per_page, :int, tag: 'itemsPerPage', namespace: 'openSearch'

    elements :entries, tag: 'entry' do
      element :property, namespace: 'dxp' do
        attribute :name, :string, namespace: nil
        attribute :value, Integer, namespace: nil
      end

      element :goal, namespace: 'ga' do
        attribute :active, 'boolean', namespace: nil
        attribute :name, 'str', namespace: nil
        attribute :number, 'int', namespace: nil
        attribute :value, :float, namespace: nil

        element :dest, tag: 'destination', namespace: 'ga' do
          attribute :case, :bool, tag: 'caseSensitive', namespace: nil
          attribute :expression, namespace: nil
          attribute :matchType, namespace: nil
          attribute :step1_required, 'bool', tag: 'step1Required', namespace: nil

          elements :steps, tag: 'step' do
            attribute :name, namespace: nil
            attribute :number, :int, namespace: nil
            attribute :path, namespace: nil
          end
        end
      end

      elements :links, tag: 'link', namespace: nil do
        attribute :rel
        attribute :type
        attribute :href
        attribute :target, tag: 'targetKind', namespace: 'gd'
      end
    end
  end
end
