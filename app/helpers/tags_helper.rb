module TagsHelper
  def heatmap(histogram={})
    html = %{<div class="heatmap">}
    _max = histogram.values.max * 2
    _min_size = 10
    _sum = histogram.values.sum.to_f
    histogram = histogram.sort { |x, y| x <=> y  }
    histogram.each do |value,nb|
      _size = (100 * nb / _sum).to_i + _min_size
      _heat = ((255 * _size)/_max).to_i
      _url = url_for(:controller => :movies,:action => :search, :q=>value)
      html << %{
                  <a href="#{_url}" class="heatmap_element" style="color: rgb(#{_heat}, #{0}, #{0}); font-size: #{_size}px; height: #{_max}px;">#{value}</a>
      }
    end
    html << %{<br style="clear: both;" /></div>}
  end
end
