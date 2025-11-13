defmodule StyleWeb.QuizFlowTest do
  use StyleWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Complete quiz flow" do
    setup do
      # Run seeds to populate questions
      Code.require_file("priv/repo/seeds/quiz_content.exs")
      :ok
    end

    test "user can complete entire quiz and submit email", %{conn: conn} do
      # 1. Visit home page
      {:ok, index_live, _html} = live(conn, "/")
      assert has_element?(index_live, "h1", "What's Your Study Style?")

      # 2. Click "Start Quiz" and follow redirect to question page
      {:ok, quiz_live, _html} =
        index_live
        |> element("button", "Start Quiz")
        |> render_click()
        |> follow_redirect(conn)

      # 3. Answer all 6 questions
      Enum.reduce(1..6, quiz_live, fn position, current_live ->
        # Should see the question
        assert has_element?(current_live, ".question-card")
        assert has_element?(current_live, "div", "Question #{position} of 6")

        # Select first answer option (the button with label "A")
        current_live
        |> element("button.answer-option", "A")
        |> render_click()

        # Click next and follow redirect
        if position < 6 do
          {:ok, next_live, _html} =
            current_live
            |> element("button", "Next")
            |> render_click()
            |> follow_redirect(conn)

          next_live
        else
          {:ok, email_live, _html} =
            current_live
            |> element("button", "Continue")
            |> render_click()
            |> follow_redirect(conn)

          email_live
        end
      end)
      |> then(fn email_live ->
        # 4. Should now see email capture form
        assert has_element?(email_live, "h1", "You're almost there!")
        assert has_element?(email_live, "input[name='email[email]']")

        # 5. Submit email
        {:ok, _result_live, _html} =
          email_live
          |> form(".email-form",
            email: %{
              email: "test@example.com",
              opt_in_courses: "true",
              opt_in_all_communications: "true"
            }
          )
          |> render_submit()
          |> follow_redirect(conn)

        # 6. Verify lead was saved to database
        lead = Style.Repo.one(Style.Quiz.Lead)
        assert lead.email == "test@example.com"
        assert lead.learning_style_slug != nil
        assert lead.opt_in_courses == true
        assert lead.opt_in_all_communications == true

        # 7. Verify quiz responses were saved
        responses = Style.Repo.all(Style.Quiz.QuizResponse)
        assert length(responses) == 6
      end)
    end
  end
end
