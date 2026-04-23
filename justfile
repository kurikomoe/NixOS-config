repo_root := justfile_directory()
skills_dir := repo_root + "/devenvs/skills"
agents_skills_dir := "~/.agents/skills"

default:
	@just --list

sync-skills: sync-code-review-skill sync-understand

update-skills:
	@printf '%s\n' 'About to update git submodule-backed skills from upstream remotes.'
	@printf '%s\n' 'This may introduce unreviewed upstream changes and potential supply-chain risk.'
	@printf '%s' 'Type UPDATE-SKILLS to continue: '
	@read -r confirm; [ "$confirm" = 'UPDATE-SKILLS' ] || { printf '%s\n' 'Aborted.'; exit 1; }
	git submodule sync --recursive
	git submodule update --init --recursive
	git submodule update --remote --recursive

sync-code-review-skill:
	mkdir -p {{agents_skills_dir}}
	ln -sfn {{skills_dir}}/code-review-skill {{agents_skills_dir}}/code-review-excellence
	printf 'synced %s\n' code-review-excellence

understand_dir := skills_dir + "/Understand-Anything"
understand_plugin_dir := understand_dir + "/understand-anything-plugin"
sync-understand:
	mkdir -p {{agents_skills_dir}}
	ln -sfn {{understand_plugin_dir}}/skills/understand {{agents_skills_dir}}/understand
	ln -sfn {{understand_plugin_dir}}/skills/understand-chat {{agents_skills_dir}}/understand-chat
	ln -sfn {{understand_plugin_dir}}/skills/understand-dashboard {{agents_skills_dir}}/understand-dashboard
	ln -sfn {{understand_plugin_dir}}/skills/understand-diff {{agents_skills_dir}}/understand-diff
	ln -sfn {{understand_plugin_dir}}/skills/understand-explain {{agents_skills_dir}}/understand-explain
	ln -sfn {{understand_plugin_dir}}/skills/understand-onboard {{agents_skills_dir}}/understand-onboard
	ln -sfn {{understand_plugin_dir}}/skills/understand-domain {{agents_skills_dir}}/understand-domain
	ln -sfn {{understand_plugin_dir}}/skills/understand-knowledge {{agents_skills_dir}}/understand-knowledge
	ln -sfn {{understand_plugin_dir}} ~/.understand-anything-plugin
	printf 'synced %s\n' understand understand-chat understand-dashboard understand-diff understand-explain understand-onboard understand-domain understand-knowledge
	printf 'synced %s\n' ~/.understand-anything-plugin
	cd {{understand_dir}} && pnpm install --frozen-lockfile 2>/dev/null || { cd {{understand_dir}} && pnpm install; }
	cd {{understand_dir}} && pnpm --filter @understand-anything/core build
	printf 'build %s\n' ~/.understand-anything-plugin
