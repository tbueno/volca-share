# frozen_string_literal: true

module AudioRegex
  extend ActiveSupport::Concern

  def audio_sample_regex
    "#{prefix}#{audio_sample_regex_body}#{suffix}"
  end

  private

  def regexes
    youtube_id = '[A-Za-z\d]{11}'
    [
      '(soundcloud\.com|snd\.sc)/[a-z\-\d]+/[a-z\-\d]+',
      'freesound\.org/people/.*/sounds/\d{2,7}',
      "youtube\\.com/watch\\?v=#{youtube_id}",
      "youtu\\.be/#{youtube_id}"
    ]
  end

  def prefix
    'https?://(.*\\.)?'
  end

  def suffix
    '/?#?(&.*)?'
  end

  def audio_sample_regex_body
    "(#{regexes.join('|')})"
  end
end
