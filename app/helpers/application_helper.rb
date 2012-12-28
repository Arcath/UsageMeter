module ApplicationHelper
  def to_kb(i)
    (i.to_f/1024).round(2)
  end
  
  def to_mb(i)
    (to_kb(i)/1024).round(2)
  end
  
  def to_gb(i)
    (to_mb(i)/1024).round(2)
  end
  
  def render_ammount(i)
    output = "#{to_kb(i)} KB"
    output = "#{to_mb(i)} MB" if i >= (900 * 1024)
    return output
  end
end
