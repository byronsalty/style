# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Style.Repo.insert!(%Style.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Load quiz content (questions, learning styles, answers)
Code.require_file("seeds/quiz_content.exs", __DIR__)
