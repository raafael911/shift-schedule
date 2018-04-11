module SchedulesHelper
  def total_time (user)
    (user.shift_hours * (1 - (Setting.plugin_shift_schedule['buffer'].to_i / 100.0))).round(2)
  end

  def user_logged_time(user, version, logged_times)
    time = 0
    if (logged_times.any?{|t|
          t[:user_id] == user.id && t[:version_id] == version.id}) then
      time = Integer(logged_times.find{|t|
        t[:user_id] == user.id && t[:version_id] == version.id
      }.hours)
    end
    time
  end

  def user_scheduled_time(user, scheduled_times)
    time = 0
      if scheduled_times.any?{|t| t[:user_id] == user.id} then
        time = scheduled_times.find{|t| t[:user_id] == user.id}.hours
      end
    time
  end

  def ava_time(user, scheduled_times)
    (total_time(user) - user_scheduled_time(user, scheduled_times)).round(2)
  end

  def sum_user_time (user, versions, schedhash)
    sum = 0
    versions.each do |v|
      sum = sum + schedhash[[user.id, v.id]]
    end
    sum.round(2)
  end

  def sum_version_time (version, users, schedhash)
    sum = 0
    users.each do |u|
      sum = sum + schedhash[[u.id, version.id]]
    end
    sum.round(2)
  end

  def sum_user_version_time (users, versions, schedhash)
    users_sum = 0
    users.each do |u|
      users_sum = users_sum + total_time(u)
    end
    versions_sum = 0
    versions.each do |v|
      versions_sum = versions_sum + sum_version_time(v, users, schedhash)
    end

    "#{versions_sum.round(2)} / #{users_sum.round(2)}"
  end

  def format_time (date)
    date.strftime('%Y %m %d').gsub!(' ','-')
  end

  def has_permission?(project)
    User.current.allowed_to?(:view_schedules, project) || User.current.allowed_to?(:edit_schedules, project)
  end

  def past_week?(date)
    curr = Integer("#{Time.now.strftime("%Y")}#{Time.now.strftime("%V")}")
    now = Integer("#{date.strftime("%Y")}#{date.strftime("%V")}")
    now < curr
  end

  def year_options
    (2015..(Date.today.year + 1)).to_a.map{|y| [y,y]}
  end
end
