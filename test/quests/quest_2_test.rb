require_relative "quest_helper"

class Quest2IntelSeedTest < QuestTestCase
  setup do
    QuestProgress.find_or_create_by!(quest_number: 1) do |quest|
      quest.status = "accepted"
      quest.accepted_at = Time.current
    end

    QuestProgress.find_or_create_by!(quest_number: 2) do |quest|
      quest.status = "unlocked"
      quest.unlocked_at = Time.current
    end
  end

  test "сервис второго квеста безопасно возвращает пустые строки без моделей первого квеста" do
    assert_equal "", Quest2DataService.all_agents
    assert_equal "", Quest2DataService.all_missions
    assert_equal "", Quest2DataService.agents_with_missions
    assert_equal "", Quest2DataService.agents_with_missions_sorted_by_mission_count
    assert_equal "", Quest2DataService.agents_with_skills
    assert_equal "", Quest2DataService.skills_by_agent_count
  end

  test "второй квест показывает первый шаг и блокирует переход дальше, пока ответ не совпал" do
    get quest_path(2)

    assert_response :success
    assert_includes response.body, "bin/rails db:seed"
    assert_includes response.body, "Quest2DataService.all_agents"
    assert_includes response.body, Quest2DataService.tasks.first[:expected_output].lines.first.strip
  end

  test "нельзя открыть второй шаг, пока первый не решён" do
    get quest_path(2, step: 2)

    assert_redirected_to quest_path(2, step: 1)
  end
end
