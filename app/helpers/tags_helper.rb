module TagsHelper
  def heatmap(histogram={})
    html = %{<div class="heatmap">}
    _max = histogram.values.max
    _min_size = 10
    _max_size = 50
    histogram = histogram.sort
    histogram.each do |tag, nb|
      _url   = url_for(:controller => :movies,:action => :search, :q=>tag)
      _heat  = nb.to_f / _max
      _size  = (_min_size + ( (_max_size-_min_size) * _heat)).to_i
      _color = "rgb(#{(204*_heat).to_i}, 16, 7)"
      html << %{
                  <a href="#{_url}" class="heatmap_element" style="color: #{_color}; font-size: #{_size}px;" alt="#{nb}">#{tag}</a>
      }
    end
    html << %{<br style="clear: both;" /></div><br />}
  end
end
