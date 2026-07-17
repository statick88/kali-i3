# Documentation Specification

## Purpose

Define requirements for a GitHub Pages documentation site covering the kali-i3 setup script, architecture, module reference, and troubleshooting.

## Requirements

### Requirement: Site Framework

The site SHALL use MkDocs with Material theme, deployed via GitHub Actions to gh-pages.

#### Scenario: Build success

- GIVEN `docs/` directory with `mkdocs.yml`
- WHEN `mkdocs build` runs
- THEN site generates without errors, all internal links resolve

#### Scenario: GitHub Actions deployment

- GIVEN code pushed to `main` with `docs/` changes
- WHEN workflow triggers
- THEN site deployed to gh-pages within 3 minutes

### Requirement: Site Structure

#### Scenario: Navigation structure

- WHEN user loads site
- THEN navigation contains: Home, Getting Started, Architecture, Configuration Reference, Module API Reference, Troubleshooting, Contributing

#### Scenario: Home page

- WHEN user visits root URL
- THEN displays: tagline, feature highlights, quick install command, badges, links to Getting Started

#### Scenario: Getting Started

- WHEN page loads
- THEN contains: prerequisites, installation steps with screenshots, first boot guide, verification

### Requirement: Architecture Documentation

#### Scenario: Module dependency diagram

- WHEN Architecture page loads
- THEN diagram shows relationships between all 8 lib/*.sh modules with dependency direction

#### Scenario: Execution flow

- WHEN Architecture page loads
- THEN flowchart shows: start → i18n init → state load → step execution → state save → cleanup

### Requirement: Configuration Reference

#### Scenario: CLI flags

- WHEN Configuration Reference loads
- THEN all flags listed: `--user-only`, `--skip-security`, `--gentle-ai`, `--no-interactive`, `--lang`
- AND each includes description, default, example

#### Scenario: Environment variables

- WHEN Environment Variables section visible
- THEN all env vars documented with name, description, default, override method

### Requirement: Module API Reference

#### Scenario: Module coverage

- WHEN Module API Reference is complete
- THEN all 8 lib/*.sh files documented as separate sub-pages: apt, colors, common, i18n, interactive, security, state, user

#### Scenario: Function documentation

- WHEN function entry is viewed
- THEN shows: name, parameters, return value, side effects, example call

### Requirement: Troubleshooting Guide

#### Scenario: Issue count

- WHEN Troubleshooting page loads
- THEN at least 20 issues listed with: symptoms, cause, solution, related screenshots

#### Scenario: Issue categorization

- WHEN page loads
- THEN issues grouped by: Installation, Configuration, Display Manager, Network, Security Tools, Performance

### Requirement: Screenshot Integration

#### Scenario: Screenshot placement

- WHEN documentation references a step or issue
- THEN screenshot embedded with alt text at relevant point

### Requirement: Search Functionality

#### Scenario: Client-side search

- WHEN site is built
- THEN search index generated automatically, works offline without external services

### Requirement: Contributing Guide

#### Scenario: Contributing content

- WHEN Contributing page loads
- THEN contains: development setup, code style, testing instructions, PR process, commit conventions

## Non-Functional Requirements

| Category | Requirement |
|----------|-------------|
| Build Time | Site MUST build in under 60 seconds |
| Page Load | Pages MUST load under 2 seconds on 3G |
| Accessibility | All images MUST have alt text; WCAG AA contrast |
| Mobile | Fully responsive on mobile devices |
| Search | Client-side index, works offline |

## Dependencies

- MkDocs >= 1.5, mkdocs-material >= 9.0, GitHub Actions
- Screenshots from VM testing phase
