build:
	pnpm wagmi generate
	pnpm tsc
	pnpm vite build
.PHONY: build

# Serve webapp in production environment (after building)
serve:
	pnpm vite preview
.PHONY: serve

# Serve webapp in dev environment (building not required)
dev:
	pnpm vite
.PHONY: dev

lint:
	pnpm eslint src --ext ts,tsx --report-unused-disable-directives --max-warnings 0
.PHONY: lint