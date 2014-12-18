class CreateCommunityPlans < ActiveRecord::Migration
  def up
    create_table :community_plans do |t|
      t.string   :community_id,             null: false
      t.integer  :plan_level,   default: 0, null: false
      t.datetime :expires_at,               null: true

      t.timestamps
    end
    # Insert plan levels for correct communities
    execute "INSERT INTO community_plans(community_id, plan_level, created_at, updated_at) SELECT communities.id AS community_id, communities.plan_level, NOW(), NOW() FROM communities"
    # If trial community AND community is created after create-trial automation => default expiration date is 30 days after the creation of that community
    execute "UPDATE community_plans, communities SET community_plans.expires_at = DATE_ADD(communities.created_at, INTERVAL 30 DAY) WHERE communities.id = community_plans.community_id AND communities.created_at > '2014-11-18 00:00:00' AND community_plans.plan_level = 0"
    # If trial community and trial is about to expire before this feature is ready => modify expiration time
    execute "UPDATE community_plans SET expires_at = '2014-12-21 13:00:00' WHERE expires_at < '2014-12-21 13:00:00' AND community_plans.plan_level = 0"

  end

  def down
    drop_table :community_plans
  end
end
