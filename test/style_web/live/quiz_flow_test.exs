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

      # 2. Click "Start Quiz"
      {:ok, quiz_live, _html} = index_live |> element("button", "Start Quiz") |> render_click() |> follow_redirect(conn)

      # 3. Answer all 6 questions
      for position <- 1..6 do
        # Should see the question
        assert has_element?(quiz_live, ".question-card")
        assert has_element?(quiz_live, "div", "Question #{position} of 6")

        # Select first answer option (A)
        quiz_live
        |> element(".answer-option", "A")
        |> render_click()

        # Click next (or last question button)
        if position < 6 do
          quiz_live = quiz_live |> element("button", "Next") |> render_click()
        else
          quiz_live = quiz_live |> element("button", "Continue") |> render_click()
        end
      end

      # 4. Should now see email capture form
      assert has_element?(quiz_live, "h1", "You're almost there!")
      assert has_element?(quiz_live, "input[name='email[email]']")

      # 5. Submit email
      quiz_live
      |> form(".email-form", email: %{email: "test@example.com"})
      |> render_submit()

      # 6. Should redirect to results
      assert_redirected(quiz_live, ~p"/result")

      # 7. Verify lead was saved to database
      lead = Style.Repo.one(Style.Quiz.Lead)
      assert lead.email == "test@example.com"
      assert lead.learning_style_slug != nil

      # 8. Verify quiz responses were saved
      responses = Style.Repo.all(Style.Quiz.QuizResponse)
      assert length(responses) == 6
    end
  end
end
