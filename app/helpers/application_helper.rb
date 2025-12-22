module ApplicationHelper
  # Format datetime with 24-hour time
  # Examples:
  #   format_datetime(time) => "Dec 22, 2025, 16:56"
  #   format_datetime(time, with_seconds: true) => "Dec 22, 2025, 16:56:30"
  def format_datetime(time, with_seconds: false)
    return nil if time.nil?
    format = with_seconds ? "%b %d, %Y, %H:%M:%S" : "%b %d, %Y, %H:%M"
    time.strftime(format)
  end

  def resend_icon
    "<svg class='w-4 h-4 text-gray-500 hover:text-gray-700 dark:text-gray-300 dark:hover:text-gray-500 cursor-pointer' xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='m22 7-8.991 5.727a2 2 0 0 1-2.009 0L2 7'/><rect x='2' y='4' width='20' height='16' rx='2'/></svg>".html_safe
  end

  def delete_icon
    "<svg class='w-4 h-4 text-red-600 hover:text-red-800 dark:text-red-300 dark:hover:text-red-500 cursor-pointer' fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16'></path></svg>".html_safe
  end
end
