# ConvertKit Integration

This directory contains services for integrating with ConvertKit (now called "Kit") API v4.

## Overview

When a user completes the quiz and provides their email with consent, they are automatically subscribed to your ConvertKit form.

## Configuration

Set this environment variable:

```bash
# Required - Your Kit V4 API key
KIT_API_KEY=your_v4_api_key_here
```

**Finding your API Key:**
- **API Key (V4)**: Kit Account → Settings → **Developer** tab → Create a V4 API Key
  - **Important**: V4 API Keys are different from V3 API Secrets. You must create a V4 key specifically.
  - V4 keys are sent via the `X-Kit-Api-Key` header (not in the request body)
  - The V4 `/subscribers` endpoint doesn't require a form ID

## Features

### Automatic Subscription
- Users are subscribed when they complete the quiz and give consent
- Only subscribes if `opt_in_courses` OR `opt_in_all_communications` is true
- Runs asynchronously to not block the quiz completion flow

### Custom Fields Sent to Kit
The following custom fields are sent with each subscription:
- `learning_style` - The user's quiz result (e.g., "Visual Learner")
- `quiz_completed_at` - ISO8601 timestamp
- `opt_in_courses` - Boolean consent flag
- `opt_in_all_communications` - Boolean consent flag

**Note:** You must create these custom fields in your Kit account first:
1. Go to Kit → Settings → Custom Fields
2. Create each field with the exact names above

### Optional: Tagging by Learning Style
You can optionally tag subscribers based on their learning style. Add this to your `config/runtime.exs`:

```elixir
config :style,
  convertkit_learning_style_tags: %{
    "visual-learner" => 123456,      # Replace with your tag IDs
    "verbal-processor" => 234567,
    "structured-planner" => 345678,
    "memorizer" => 456789
  }
```

**Finding tag IDs:**
1. Go to Kit → Subscribers → Tags
2. Click on a tag
3. The ID is in the URL: `kit.com/subscribers/tags/{ID}`

## Modules

### `Style.Services.ConvertKitClient`
Low-level API client for making requests to the Kit API v4.

**Functions:**
- `subscribe_to_form/2` - Subscribe a user to a form
- `tag_subscriber/2` - Add a tag to a subscriber

### `Style.Services.ConvertKitSubscriber`
High-level service for subscribing quiz leads.

**Functions:**
- `subscribe_lead/1` - Main entry point, handles consent checks and calls the API
- `convertkit_enabled?/0` - Check if Kit integration is configured

## Testing

### In Development
Set the environment variables in your local environment:

```bash
export KIT_API_KEY="your_key"
export KIT_FORM_ID="your_form_id"
```

Then complete a quiz with a test email to verify the integration works.

### Disabling in Development
Simply don't set the environment variables and the integration will be automatically disabled.

### Monitoring
All ConvertKit operations are logged at the `info` level for successful operations and `error` level for failures.

Check your logs for messages like:
- "Successfully subscribed user@example.com to ConvertKit"
- "Skipping ConvertKit subscription for user@example.com - no consent given"
- "ConvertKit integration is disabled"

## Error Handling

The integration is designed to fail gracefully:
- If Kit API is down, the user still completes the quiz successfully
- Errors are logged but don't block the user experience
- The subscription happens asynchronously in a separate process

## API Rate Limits

Kit API v4 rate limit: **120 requests per 60 seconds** per API key.

For high-traffic applications, consider implementing a queue system or batch processing.

## Security Notes

- Never commit your API keys to version control
- Use environment variables for all credentials
- The API key is sent as part of the request body (not in headers)
- Kit API uses HTTPS for all requests

## Resources

- [Kit API v4 Documentation](https://developers.kit.com/v4)
- [Kit Developer Portal](https://developers.kit.com/)
