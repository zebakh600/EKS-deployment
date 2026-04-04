-- ============================================================
-- SEED TOPICS
-- ============================================================
INSERT INTO topics (name, slug, description, icon, color) VALUES
('Linux', 'linux', 'Linux OS fundamentals, commands, and administration', 'terminal', '#F97316'),
('Git', 'git', 'Version control with Git and branching strategies', 'git-branch', '#EF4444'),
('Docker', 'docker', 'Containerization with Docker and Docker Compose', 'box', '#3B82F6'),
('Jenkins', 'jenkins', 'CI/CD pipelines with Jenkins', 'settings', '#D97706'),
('Kubernetes', 'kubernetes', 'Container orchestration with Kubernetes', 'cloud', '#8B5CF6'),
('GitHub', 'github', 'GitHub platform and collaboration workflows', 'github', '#6B7280'),
('GitHub Actions', 'github-actions', 'Workflow automation with GitHub Actions', 'zap', '#10B981'),
('Ansible', 'ansible', 'Infrastructure automation with Ansible', 'server', '#EC4899'),
('Prometheus', 'prometheus', 'Metrics collection with Prometheus', 'activity', '#F59E0B'),
('Grafana', 'grafana', 'Visualization and dashboards with Grafana', 'bar-chart', '#06B6D4'),
('CI/CD', 'cicd', 'Continuous Integration and Continuous Delivery concepts', 'repeat', '#14B8A6')
ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- SEED QUESTIONS (~100 across all topics)
-- ============================================================

-- LINUX (10 questions)
INSERT INTO questions (topic_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
SELECT t.id,
    q.question_text, q.option_a, q.option_b, q.option_c, q.option_d, q.correct_option, q.explanation, q.difficulty
FROM topics t, (VALUES
    ('What command shows currently running processes?', 'ls -la', 'ps aux', 'top -n', 'jobs -l', 'B', 'ps aux lists all running processes with details. top is interactive, ls is for files, jobs is for shell jobs.', 'easy'),
    ('Which command changes file permissions?', 'chown', 'chmod', 'chgrp', 'chattr', 'B', 'chmod (change mode) modifies file permissions. chown changes ownership, chgrp changes group, chattr changes attributes.', 'easy'),
    ('What does the command "df -h" display?', 'Directory files in human-readable format', 'Disk free space in human-readable format', 'Default file hierarchy', 'Disk filesystem headers', 'B', 'df -h shows disk space usage for all mounted filesystems in human-readable units (KB, MB, GB).', 'easy'),
    ('Which signal does "kill -9" send?', 'SIGTERM', 'SIGHUP', 'SIGKILL', 'SIGSTOP', 'C', 'kill -9 sends SIGKILL which immediately terminates a process. SIGTERM (15) allows graceful shutdown.', 'medium'),
    ('What is the purpose of /etc/fstab?', 'List of user accounts', 'Filesystem mount configuration at boot', 'Network interface configuration', 'System log rotation config', 'B', '/etc/fstab defines how disk partitions and other block devices are mounted at system startup.', 'medium'),
    ('Which command finds files modified in the last 7 days?', 'find / -mtime -7', 'locate -d 7', 'ls -t --days=7', 'grep -r --days 7', 'A', 'find with -mtime -7 finds files modified less than 7 days ago. The minus sign means "less than".', 'medium'),
    ('What does "sudo !!" do?', 'Runs the sudo command twice', 'Re-runs the last command with sudo', 'Cancels the last sudo command', 'Shows sudo history', 'B', '!! expands to the last command, so sudo !! re-runs your previous command with elevated privileges.', 'hard'),
    ('Which file contains user password hashes in modern Linux?', '/etc/passwd', '/etc/shadow', '/etc/security', '/etc/auth', 'B', '/etc/shadow stores hashed passwords and is readable only by root. /etc/passwd only stores user info now.', 'medium'),
    ('What does "awk NR==2" do in a pipeline?', 'Prints every second character', 'Prints the second line', 'Skips the second record', 'Counts to 2 lines', 'B', 'NR is the current record number. NR==2 matches when awk is processing the second line/record.', 'hard'),
    ('Which command shows network connections and listening ports?', 'ifconfig -a', 'netstat -tulpn', 'route -n', 'ping -l', 'B', 'netstat -tulpn shows TCP/UDP listening ports and established connections with process IDs.', 'medium')
) AS q(question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
WHERE t.slug = 'linux';

-- GIT (10 questions)
INSERT INTO questions (topic_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
SELECT t.id,
    q.question_text, q.option_a, q.option_b, q.option_c, q.option_d, q.correct_option, q.explanation, q.difficulty
FROM topics t, (VALUES
    ('What command creates a new branch and switches to it?', 'git branch new-branch', 'git checkout -b new-branch', 'git switch new-branch', 'git create new-branch', 'B', 'git checkout -b creates and switches to a new branch. In newer Git, git switch -c also works.', 'easy'),
    ('How do you undo the last commit but keep changes staged?', 'git revert HEAD', 'git reset --soft HEAD~1', 'git reset --hard HEAD~1', 'git checkout HEAD~1', 'B', 'git reset --soft HEAD~1 moves HEAD back one commit while keeping all changes staged (in the index).', 'medium'),
    ('What is a git "stash"?', 'A remote repository backup', 'Temporary storage for uncommitted changes', 'A branch protection rule', 'A compressed commit', 'B', 'git stash temporarily shelves changes so you can work on something else without committing.', 'easy'),
    ('Which merge strategy preserves all commits from a feature branch?', 'git merge --squash', 'git merge --no-ff', 'git merge --ff-only', 'git merge --rebase', 'B', '--no-ff creates a merge commit even when fast-forward is possible, preserving branch history.', 'medium'),
    ('What does git cherry-pick do?', 'Selects best commits automatically', 'Applies a specific commit to the current branch', 'Removes unwanted commits', 'Lists commits by author', 'B', 'git cherry-pick applies changes from a specific commit onto the current branch.', 'medium'),
    ('What is the purpose of .gitignore?', 'Lists ignored git configuration', 'Specifies files Git should not track', 'Blocks certain users from committing', 'Ignores merge conflicts', 'B', '.gitignore tells Git which files and directories to ignore and not track in version control.', 'easy'),
    ('What does "git fetch" do compared to "git pull"?', 'They are identical commands', 'fetch downloads changes without merging; pull downloads and merges', 'fetch only works with origin; pull works with all remotes', 'pull is faster than fetch', 'B', 'git fetch downloads remote changes to your local repo but does not merge them into your working branch.', 'medium'),
    ('How do you delete a remote branch?', 'git branch -d origin/branch', 'git push origin --delete branch', 'git remote remove branch', 'git checkout -D origin/branch', 'B', 'git push origin --delete <branch> deletes the branch from the remote repository.', 'medium'),
    ('What is git rebase used for?', 'Backing up a repository', 'Reapplying commits on top of another base commit', 'Resetting branch to remote state', 'Rebasing origin URL', 'B', 'git rebase moves or replays commits from one branch onto another, creating a linear history.', 'hard'),
    ('What does HEAD~3 refer to?', 'The third branch from HEAD', 'Three commits before the current HEAD', 'HEAD with 3 staged files', 'The third remote branch', 'B', 'HEAD~3 (or HEAD~~~) refers to the commit that is 3 ancestors behind the current HEAD.', 'medium')
) AS q(question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
WHERE t.slug = 'git';

-- DOCKER (10 questions)
INSERT INTO questions (topic_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
SELECT t.id,
    q.question_text, q.option_a, q.option_b, q.option_c, q.option_d, q.correct_option, q.explanation, q.difficulty
FROM topics t, (VALUES
    ('What is the difference between a Docker image and a container?', 'They are the same thing', 'An image is a blueprint; a container is a running instance', 'A container is read-only; an image is writable', 'Images run on the host; containers run in the cloud', 'B', 'A Docker image is a read-only template. A container is a runnable instance created from that image.', 'easy'),
    ('Which Dockerfile instruction sets the base image?', 'BASE', 'FROM', 'IMAGE', 'START', 'B', 'FROM is the first instruction in a Dockerfile and specifies the base image to build upon.', 'easy'),
    ('What does "docker-compose up -d" do?', 'Starts only databases in detached mode', 'Starts all services in detached (background) mode', 'Downloads images without starting', 'Builds without starting containers', 'B', '-d flag stands for detached mode, running containers in the background.', 'easy'),
    ('What is a multi-stage Docker build used for?', 'Building on multiple hosts', 'Reducing final image size by separating build and runtime stages', 'Running multiple Dockerfiles', 'Caching multiple layers', 'B', 'Multi-stage builds let you use one stage for building and copy only artifacts to the final slim image.', 'medium'),
    ('Which command shows logs for a running container?', 'docker inspect', 'docker logs <container>', 'docker stats', 'docker events', 'B', 'docker logs retrieves the log output of a container. Use -f flag to follow logs in real time.', 'easy'),
    ('What does the EXPOSE instruction in a Dockerfile do?', 'Opens the port on the host', 'Documents which port the container listens on at runtime', 'Blocks all other ports', 'Automatically publishes the port', 'B', 'EXPOSE documents the intended port but does not actually publish it. You need -p in docker run to publish.', 'medium'),
    ('What is a Docker volume used for?', 'Networking between containers', 'Persisting data beyond container lifecycle', 'Setting environment variables', 'Limiting CPU usage', 'B', 'Docker volumes persist data generated by containers so data survives container restarts and removal.', 'easy'),
    ('What command removes all stopped containers, unused images, and networks?', 'docker rm -a', 'docker system prune', 'docker clean all', 'docker purge', 'B', 'docker system prune removes all stopped containers, dangling images, unused networks, and build cache.', 'medium'),
    ('What is the difference between COPY and ADD in Dockerfile?', 'ADD is faster than COPY', 'ADD supports URLs and tar extraction; COPY only copies local files', 'COPY supports compression; ADD does not', 'They are identical', 'B', 'ADD can fetch from URLs and auto-extract archives. COPY is preferred for simple local file copies.', 'medium'),
    ('How do you pass environment variables to a container at runtime?', 'EXPOSE VAR=value', 'docker run -e VAR=value', 'docker run --environment VAR', 'ENV VAR=value at runtime', 'B', 'The -e flag (or --env) in docker run sets environment variables in the container at startup.', 'easy')
) AS q(question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
WHERE t.slug = 'docker';

-- JENKINS (9 questions)
INSERT INTO questions (topic_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
SELECT t.id,
    q.question_text, q.option_a, q.option_b, q.option_c, q.option_d, q.correct_option, q.explanation, q.difficulty
FROM topics t, (VALUES
    ('What file defines a Jenkins Pipeline as Code?', 'jenkins.yml', 'Jenkinsfile', 'pipeline.groovy', 'build.xml', 'B', 'A Jenkinsfile is a text file containing the definition of a Jenkins Pipeline, checked into source control.', 'easy'),
    ('What are the two types of Jenkins Pipeline syntax?', 'Scripted and Compiled', 'Declarative and Scripted', 'Sequential and Parallel', 'Freestyle and Pipeline', 'B', 'Jenkins supports Declarative Pipeline (structured, easier) and Scripted Pipeline (Groovy-based, flexible).', 'easy'),
    ('What is a Jenkins agent?', 'A plugin manager component', 'A machine that executes the pipeline steps', 'The Jenkins web UI', 'A build trigger mechanism', 'B', 'A Jenkins agent (formerly slave) is a node that runs pipeline steps delegated by the Jenkins master.', 'medium'),
    ('Which directive defines environment variables in a Declarative Pipeline?', 'vars { }', 'environment { }', 'config { }', 'globals { }', 'B', 'The environment directive in a Declarative Pipeline sets environment variables available to all steps.', 'medium'),
    ('What does the "post" section do in a Jenkinsfile?', 'Posts build results to Slack', 'Defines actions to run after pipeline completion', 'Creates post-build artifacts', 'Configures post webhooks', 'B', 'The post section defines steps to run after the pipeline or stage finishes, like always, success, or failure.', 'medium'),
    ('What is Jenkins Blue Ocean?', 'A Docker integration plugin', 'A modern UI and visualization for Jenkins Pipelines', 'A cloud deployment tool', 'A Jenkins backup solution', 'B', 'Blue Ocean is a rethought Jenkins UI providing a modern visual pipeline editor and cleaner dashboard.', 'easy'),
    ('How do you parameterize a Jenkins build?', 'Use the params{} block in Jenkinsfile', 'Add parameters { } directive in a Declarative Pipeline', 'Set environment variables in the agent', 'Use the config section', 'B', 'The parameters directive lets you define user-supplied inputs like string, boolean, or choice parameters.', 'medium'),
    ('What is the purpose of Jenkins shared libraries?', 'Sharing build artifacts between jobs', 'Reusable Groovy code shared across multiple Pipelines', 'Shared plugin configurations', 'A library of Jenkins plugins', 'B', 'Shared Libraries let teams define common pipeline logic in a central repo and reuse it across Jenkinsfiles.', 'hard'),
    ('Which trigger runs a Jenkins build on a schedule?', 'pollSCM', 'cron in triggers directive', 'schedule { }', 'timer { }', 'B', 'triggers { cron("H/15 * * * *") } in a Declarative Pipeline triggers builds on a cron schedule.', 'medium')
) AS q(question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
WHERE t.slug = 'jenkins';

-- KUBERNETES (10 questions)
INSERT INTO questions (topic_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
SELECT t.id,
    q.question_text, q.option_a, q.option_b, q.option_c, q.option_d, q.correct_option, q.explanation, q.difficulty
FROM topics t, (VALUES
    ('What is the smallest deployable unit in Kubernetes?', 'Container', 'Pod', 'Node', 'Deployment', 'B', 'A Pod is the smallest deployable unit in Kubernetes and can contain one or more containers sharing storage and network.', 'easy'),
    ('What does a Kubernetes Deployment manage?', 'Network routing', 'Desired state of ReplicaSets and Pods', 'Persistent storage', 'Node scheduling', 'B', 'A Deployment manages a ReplicaSet to ensure the desired number of pod replicas are running and handles rolling updates.', 'easy'),
    ('What is the purpose of a Kubernetes Service?', 'Running batch jobs', 'Stable network endpoint to access a set of Pods', 'Storing configuration data', 'Scheduling pod placement', 'B', 'A Service provides a stable IP/DNS and load balances traffic to pods matching a selector, even as pods restart.', 'easy'),
    ('What is a ConfigMap used for?', 'Storing TLS certificates', 'Storing non-sensitive configuration data', 'Storing container images', 'Network configuration', 'B', 'ConfigMaps store non-secret configuration data as key-value pairs that pods can consume as env vars or volume mounts.', 'easy'),
    ('What is the difference between a StatefulSet and a Deployment?', 'StatefulSets are faster', 'StatefulSets provide stable pod identity and ordered deployment for stateful apps', 'Deployments support persistent volumes; StatefulSets do not', 'They are identical', 'B', 'StatefulSets give pods stable hostnames, persistent storage, and ordered rolling updates — needed for databases.', 'medium'),
    ('What command displays all pods in all namespaces?', 'kubectl get pods', 'kubectl get pods --all-namespaces', 'kubectl list pods -A', 'kubectl describe pods --global', 'B', 'kubectl get pods --all-namespaces (or -A shorthand) shows pods across every namespace in the cluster.', 'easy'),
    ('What is a Kubernetes Ingress?', 'A type of Service for internal traffic', 'An API object managing external HTTP/HTTPS routing to Services', 'A firewall rule', 'A network policy', 'B', 'Ingress exposes HTTP and HTTPS routes from outside the cluster to services, with rules for routing based on host/path.', 'medium'),
    ('What does a PersistentVolumeClaim (PVC) do?', 'Claims network bandwidth', 'Requests storage resources from a PersistentVolume', 'Creates a new volume type', 'Monitors volume usage', 'B', 'A PVC is a request for storage by a user. It binds to a PersistentVolume that satisfies the requested capacity and access mode.', 'medium'),
    ('What is the role of etcd in Kubernetes?', 'Container runtime', 'Distributed key-value store for all cluster state', 'Load balancer', 'Container image registry', 'B', 'etcd is the consistent and highly-available key-value store used as the backing store for all Kubernetes cluster data.', 'hard'),
    ('What does kubectl rollout undo deployment/myapp do?', 'Deletes the deployment', 'Rolls back to the previous deployment revision', 'Pauses the deployment', 'Scales to zero replicas', 'B', 'kubectl rollout undo rolls back a Deployment to its previous revision, restoring the previous pod template spec.', 'medium')
) AS q(question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
WHERE t.slug = 'kubernetes';

-- GITHUB (8 questions)
INSERT INTO questions (topic_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
SELECT t.id,
    q.question_text, q.option_a, q.option_b, q.option_c, q.option_d, q.correct_option, q.explanation, q.difficulty
FROM topics t, (VALUES
    ('What is a Pull Request in GitHub?', 'A request to download code', 'A request to merge changes from one branch into another', 'A request for repository access', 'A payment request for private repos', 'B', 'A Pull Request (PR) proposes changes and requests code review before merging a branch into another.', 'easy'),
    ('What is GitHub Pages used for?', 'Hosting Docker containers', 'Hosting static websites directly from a repository', 'Creating API documentation', 'Managing team access', 'B', 'GitHub Pages hosts static websites directly from a GitHub repository, supporting HTML, CSS, JS, and Jekyll.', 'easy'),
    ('What is the purpose of a CODEOWNERS file?', 'Lists copyright owners', 'Defines who must review changes to specific files', 'Sets file encoding rules', 'Restricts who can clone the repo', 'B', 'CODEOWNERS defines individuals/teams responsible for code. They are auto-requested for review on PRs touching their files.', 'medium'),
    ('What does "fork" mean in GitHub context?', 'Delete a repository', 'Create a personal copy of someone else''s repository', 'Split a repo into two branches', 'Archive a repository', 'B', 'Forking creates your own copy of a repository under your account so you can freely experiment without affecting the original.', 'easy'),
    ('What is a GitHub Release?', 'A scheduled code review', 'A packaged version of software with changelogs and assets', 'A branch protection rule', 'A CI/CD trigger', 'B', 'Releases mark specific points in history (tags) and can include compiled binaries, release notes, and changelogs.', 'medium'),
    ('What is branch protection in GitHub?', 'Encrypting a branch', 'Rules preventing direct pushes and requiring reviews/checks', 'Making a branch read-only for all users', 'Restricting branch to one contributor', 'B', 'Branch protection rules enforce workflows like requiring PR reviews, passing status checks, or signed commits before merging.', 'medium'),
    ('What is a GitHub Organization?', 'A paid GitHub plan', 'A shared account for team collaboration with fine-grained access', 'A type of repository', 'A GitHub Actions runner', 'B', 'Organizations let teams collaborate across many repositories with shared billing and role-based access control.', 'easy'),
    ('What are GitHub Secrets used for?', 'Encrypting public repositories', 'Storing sensitive values used in GitHub Actions workflows', 'Managing user passwords', 'Hidden repository settings', 'B', 'Secrets are encrypted environment variables stored in GitHub and injected into Actions workflows at runtime.', 'medium')
) AS q(question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
WHERE t.slug = 'github';

-- GITHUB ACTIONS (9 questions)
INSERT INTO questions (topic_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
SELECT t.id,
    q.question_text, q.option_a, q.option_b, q.option_c, q.option_d, q.correct_option, q.explanation, q.difficulty
FROM topics t, (VALUES
    ('Where are GitHub Actions workflow files stored?', '.github/workflows/', 'actions/', '.ci/', 'workflows/', 'A', 'Workflow files are YAML files stored in the .github/workflows/ directory of a repository.', 'easy'),
    ('What is a GitHub Actions "runner"?', 'A workflow trigger', 'The server/machine that executes workflow jobs', 'A type of action', 'A CI dashboard', 'B', 'A runner is a server that runs jobs in a workflow. GitHub provides hosted runners or you can self-host your own.', 'easy'),
    ('What keyword triggers a workflow on push to main?', 'trigger: push: main', 'on: push: branches: [main]', 'when: push: main', 'event: push main', 'B', 'The on: key defines triggers. on: push: branches: [main] fires the workflow on pushes to the main branch.', 'easy'),
    ('What is the purpose of "needs" in a job definition?', 'Lists required packages', 'Defines job dependencies to enforce execution order', 'Specifies hardware requirements', 'Lists environment secrets needed', 'B', 'needs: creates job dependencies. A job with needs: [build] only runs after the build job completes successfully.', 'medium'),
    ('What is a composite action in GitHub Actions?', 'An action combining multiple languages', 'An action that bundles multiple steps into a reusable action', 'A Docker container action', 'An action with multiple outputs', 'B', 'Composite actions let you combine multiple workflow steps into a single reusable action defined in action.yml.', 'hard'),
    ('How do you pass outputs between jobs in GitHub Actions?', 'Use shared environment variables', 'Use job outputs and needs context to reference them', 'Write to a shared file', 'Use repository secrets', 'B', 'Set outputs in one job using echo name=value >> $GITHUB_OUTPUT and reference with needs.job.outputs.name in another.', 'hard'),
    ('What does "uses: actions/checkout@v4" do?', 'Checks out a specific branch to review', 'Clones the repository into the runner workspace', 'Validates the action version', 'Checks out GitHub marketplace actions', 'B', 'actions/checkout checks out your repository so the workflow can access its code and files.', 'easy'),
    ('What is a self-hosted runner?', 'A GitHub-managed premium runner', 'Your own machine registered to run GitHub Actions jobs', 'A Docker runner image', 'A scheduled runner', 'B', 'Self-hosted runners are machines you manage yourself, useful for custom hardware, private networks, or cost savings.', 'medium'),
    ('What is the matrix strategy in GitHub Actions used for?', 'Creating a dependency matrix', 'Running a job with multiple variable combinations in parallel', 'Mapping secrets to environments', 'Defining job priority order', 'B', 'matrix strategy runs jobs across multiple configurations (e.g., different OS or language versions) automatically in parallel.', 'medium')
) AS q(question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
WHERE t.slug = 'github-actions';

-- ANSIBLE (9 questions)
INSERT INTO questions (topic_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
SELECT t.id,
    q.question_text, q.option_a, q.option_b, q.option_c, q.option_d, q.correct_option, q.explanation, q.difficulty
FROM topics t, (VALUES
    ('What language are Ansible playbooks written in?', 'JSON', 'YAML', 'XML', 'HCL', 'B', 'Ansible playbooks are written in YAML, a human-readable data serialization format.', 'easy'),
    ('What is an Ansible inventory?', 'A list of installed modules', 'A list of managed hosts/groups', 'A log of executed tasks', 'A list of roles', 'B', 'The inventory defines the hosts and groups of hosts that Ansible manages and can run playbooks against.', 'easy'),
    ('What is an Ansible role?', 'A user permission level', 'A reusable, structured unit of automation', 'A remote connection type', 'A type of playbook', 'B', 'Roles provide a framework for organizing playbooks, variables, tasks, handlers, templates, and files in a standardized structure.', 'medium'),
    ('What is the purpose of Ansible handlers?', 'Handle errors in tasks', 'Tasks triggered by notifications, run once at end of play', 'Handle SSH connections', 'Manage role dependencies', 'B', 'Handlers are tasks triggered by notify directives and run once at the end of a play if notified, e.g., restarting a service.', 'medium'),
    ('What does "idempotent" mean in Ansible context?', 'Running playbooks in parallel', 'Running the same task multiple times produces the same result', 'Using immutable infrastructure', 'Idempotent means zero-downtime', 'B', 'Ansible tasks are designed to be idempotent: re-running a playbook only makes changes if the system state differs from desired state.', 'medium'),
    ('What connection method does Ansible use by default?', 'WinRM', 'SSH', 'Telnet', 'REST API', 'B', 'Ansible uses SSH to connect to Linux/Unix managed nodes by default. No agent is required on managed hosts.', 'easy'),
    ('What is Ansible Vault used for?', 'Storing role metadata', 'Encrypting sensitive data like passwords and keys', 'Caching playbook results', 'Version-locking playbooks', 'B', 'Ansible Vault encrypts sensitive data (passwords, keys, secrets) that are stored in playbooks or variable files.', 'medium'),
    ('What does the "when" keyword do in a task?', 'Sets task timeout', 'Adds a conditional to run a task only when true', 'Schedules task execution time', 'Defines task ordering', 'B', 'The when keyword adds conditionals to tasks, running them only when the expression evaluates to true.', 'easy'),
    ('What is ansible-galaxy used for?', 'Monitoring Ansible runs', 'Downloading and sharing reusable roles and collections', 'Running playbooks on cloud', 'Managing Ansible licenses', 'B', 'Ansible Galaxy is a hub for finding, reusing, and sharing Ansible content like roles and collections.', 'medium')
) AS q(question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
WHERE t.slug = 'ansible';

-- PROMETHEUS (9 questions)
INSERT INTO questions (topic_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
SELECT t.id,
    q.question_text, q.option_a, q.option_b, q.option_c, q.option_d, q.correct_option, q.explanation, q.difficulty
FROM topics t, (VALUES
    ('What data model does Prometheus use?', 'Relational tables', 'Time-series with metric name and key-value labels', 'Document-based JSON', 'Graph nodes and edges', 'B', 'Prometheus stores all data as time series: streams of timestamped values identified by metric name and key-value label sets.', 'easy'),
    ('How does Prometheus collect metrics?', 'Agents push to Prometheus', 'Prometheus scrapes (pulls) from HTTP endpoints', 'Via message queues', 'Via syslog forwarding', 'B', 'Prometheus uses a pull model, scraping metrics from configured HTTP endpoints (exporters) at regular intervals.', 'easy'),
    ('What is PromQL?', 'Prometheus Quick Language', 'Prometheus Query Language for selecting and aggregating time series', 'A Prometheus config format', 'A metric push protocol', 'B', 'PromQL is Prometheus Query Language, used to query and aggregate time-series data for graphs and alerts.', 'easy'),
    ('What is an exporter in Prometheus?', 'A dashboard export tool', 'A process that exposes metrics from a system for scraping', 'A Prometheus backup agent', 'An alerting component', 'B', 'Exporters are processes that translate metrics from third-party systems (e.g., node_exporter for OS metrics) into the Prometheus format.', 'medium'),
    ('What are the four core metric types in Prometheus?', 'Int, Float, String, Boolean', 'Counter, Gauge, Histogram, Summary', 'Rate, Average, Sum, Count', 'Push, Pull, Stream, Batch', 'B', 'Prometheus has four metric types: Counter (monotonically increasing), Gauge (up/down), Histogram, and Summary.', 'medium'),
    ('What is the Alertmanager in Prometheus?', 'The Prometheus UI', 'Handles alerts: deduplication, grouping, and routing to receivers', 'A metric storage backend', 'A service discovery tool', 'B', 'Alertmanager receives alerts from Prometheus, deduplicates them, groups them, and routes to receivers like email or PagerDuty.', 'medium'),
    ('What does the "rate()" function do in PromQL?', 'Returns total count', 'Calculates per-second rate of a counter over a time range', 'Converts gauge to counter', 'Rounds metric values', 'B', 'rate() calculates the per-second average rate of increase of a counter over a specified time window.', 'hard'),
    ('What is service discovery in Prometheus?', 'Finding microservices automatically', 'Automatically discovering scrape targets from sources like Kubernetes', 'DNS lookup for Prometheus', 'Plugin for service mesh', 'B', 'Prometheus supports many service discovery mechanisms (Kubernetes, EC2, Consul) to dynamically find scrape targets.', 'hard'),
    ('What file configures Prometheus scrape targets?', 'targets.json', 'prometheus.yml', 'scrape_config.yaml', 'prometheus.conf', 'B', 'prometheus.yml is the main configuration file, where you define scrape_configs with target endpoints and intervals.', 'easy')
) AS q(question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
WHERE t.slug = 'prometheus';

-- GRAFANA (8 questions)
INSERT INTO questions (topic_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
SELECT t.id,
    q.question_text, q.option_a, q.option_b, q.option_c, q.option_d, q.correct_option, q.explanation, q.difficulty
FROM topics t, (VALUES
    ('What is Grafana primarily used for?', 'Log storage', 'Visualization and monitoring dashboards for metrics data', 'Container orchestration', 'CI/CD pipeline management', 'B', 'Grafana is an open-source platform for monitoring and observability, providing dashboards and visualization of metrics.', 'easy'),
    ('What is a Grafana data source?', 'A SQL database Grafana creates', 'An external system Grafana queries for data (e.g., Prometheus)', 'A Grafana plugin store', 'A built-in metrics collector', 'B', 'Data sources are the backends Grafana queries: Prometheus, InfluxDB, Elasticsearch, CloudWatch, and many others.', 'easy'),
    ('What are Grafana panels?', 'UI navigation panels', 'Individual visualization units within a dashboard', 'Alert notification channels', 'Permission control modules', 'B', 'Panels are the building blocks of Grafana dashboards, each containing a visualization like graphs, tables, or stat displays.', 'easy'),
    ('What is a Grafana template variable?', 'A reusable dashboard layout', 'A dynamic variable allowing interactive filtering of dashboard data', 'A Grafana config parameter', 'An alert template', 'B', 'Template variables create interactive dashboards where users can filter by host, service, or environment using dropdowns.', 'medium'),
    ('What is Grafana Loki?', 'A Grafana plugin', 'A horizontally-scalable log aggregation system designed to work with Grafana', 'A Grafana alerting component', 'A tracing backend', 'B', 'Loki is a log aggregation system from Grafana Labs, designed to be cost-effective and integrates natively with Grafana.', 'medium'),
    ('How are Grafana dashboards stored as code?', 'As Python scripts', 'As JSON files that can be version-controlled', 'As XML configuration', 'As Lua scripts', 'B', 'Grafana dashboards are JSON documents and can be exported, imported, and stored in version control for GitOps workflows.', 'medium'),
    ('What is Grafana Alerting used for?', 'Creating alert sounds', 'Sending notifications when metrics cross defined thresholds', 'Monitoring alert logs', 'Alert-based scaling', 'B', 'Grafana Alerting evaluates rules against data sources and sends notifications via email, Slack, PagerDuty, and others.', 'easy'),
    ('What is the purpose of Grafana provisioning?', 'Providing Grafana licenses', 'Automatically configuring data sources and dashboards via config files', 'Provisioning cloud servers', 'Setting up user accounts in bulk', 'B', 'Provisioning lets you configure Grafana data sources, dashboards, and plugins automatically via YAML/JSON files on startup.', 'hard')
) AS q(question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
WHERE t.slug = 'grafana';

-- CI/CD (9 questions)
INSERT INTO questions (topic_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
SELECT t.id,
    q.question_text, q.option_a, q.option_b, q.option_c, q.option_d, q.correct_option, q.explanation, q.difficulty
FROM topics t, (VALUES
    ('What is Continuous Integration (CI)?', 'Integrating with cloud providers continuously', 'Automatically building and testing code on every commit', 'Continuously deploying to production', 'Monitoring integration between services', 'B', 'CI is the practice of frequently merging code changes into a shared repo, triggering automated builds and tests.', 'easy'),
    ('What is the difference between Continuous Delivery and Continuous Deployment?', 'They are the same', 'Delivery requires manual approval; Deployment deploys automatically to production', 'Deployment requires manual approval; Delivery is automated', 'Delivery is for staging; Deployment is for development', 'B', 'Continuous Delivery automates up to production-ready but needs approval. Continuous Deployment goes all the way to production automatically.', 'medium'),
    ('What is a deployment pipeline?', 'A network pipe for deployments', 'An automated sequence of steps from code commit to production', 'A Jenkins plugin', 'A type of Git branch', 'B', 'A deployment pipeline is an automated process that takes code from version control through build, test, and deployment stages.', 'easy'),
    ('What is a "blue-green deployment"?', 'Using blue and green as UI themes', 'Running two identical environments and switching traffic between them', 'A Kubernetes rolling update strategy', 'A multi-region deployment pattern', 'B', 'Blue-green maintains two identical production environments. New version deploys to green; traffic switches from blue to green for zero-downtime releases.', 'medium'),
    ('What is a canary deployment?', 'Deploying to a test environment', 'Gradually rolling out a release to a small subset of users first', 'A hotfix deployment strategy', 'A rollback mechanism', 'B', 'Canary releases send a small percentage of traffic to the new version first, monitoring for errors before full rollout.', 'medium'),
    ('What is "shift left" in DevOps?', 'Moving teams to the left side of the org chart', 'Moving testing and security earlier in the development lifecycle', 'Using left-to-right pipeline flow', 'Shifting on-call responsibility left', 'B', 'Shift left means performing testing, security scanning, and quality checks earlier in development rather than at the end.', 'medium'),
    ('What is infrastructure as code (IaC)?', 'Writing code for cloud functions', 'Managing infrastructure through machine-readable definition files', 'Code that runs infrastructure processes', 'An AWS-specific tool', 'B', 'IaC lets you define and manage cloud infrastructure using code (Terraform, CloudFormation) for reproducibility and version control.', 'easy'),
    ('What is a feature flag?', 'A Git branch flag', 'A mechanism to enable/disable features in production without deploying', 'A flag in CI config', 'A code review checkbox', 'B', 'Feature flags let you toggle features on/off at runtime without new deployments, enabling dark launches and A/B testing.', 'medium'),
    ('What is mean time to recovery (MTTR)?', 'Average time between releases', 'Average time to restore service after an incident', 'Time to run full test suite', 'Mean time to resolve PRs', 'B', 'MTTR measures the average time it takes to recover from a failure or incident — a key DORA metric for DevOps performance.', 'hard')
) AS q(question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty)
WHERE t.slug = 'cicd';
