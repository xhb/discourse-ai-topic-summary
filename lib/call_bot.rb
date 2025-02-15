# frozen_string_literal: true
require "openai"
require "json"

class ::AiTopicSummary::CallBot
  # see https://github.com/alexrudall/ruby-openai
  def self.get_response(full_raw)

    # TODO consider moving this to a job which retries on failure, current timeout at time of comment is 120 seconds, though

    client = ::OpenAI::Client.new(
      access_token: SiteSetting.ai_topic_summary_open_ai_token,
      uri_base: SiteSetting.ai_topic_summary_open_ai_uri_base,
      request_timeout: SiteSetting.ai_topic_summary_open_ai_request_timeout
    )

    response = client.completions(
      parameters: {
          model: SiteSetting.ai_topic_summary_open_ai_model,
          prompt: full_raw,
          max_tokens: SiteSetting.ai_topic_summary_max_response_tokens
      })

    if response.parsed_response["error"]
      raise StandardError, response.parsed_response["error"]["message"]
    end

    hash_res = JSON.parse(response.body)
    hash_res.dig("choices", 0, "text")
  end
end
