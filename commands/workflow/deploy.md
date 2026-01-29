# /deploy - Deployment Workflow

Guide through a safe deployment process.

## Usage

```
/deploy [environment]
/deploy staging
/deploy production
```

## Pre-Deployment Checklist

### 1. Code Readiness

```markdown
## Pre-Deploy Checks

### Code
- [ ] All tests passing
- [ ] No linting errors
- [ ] Code reviewed and approved
- [ ] No console.log or debug statements
- [ ] Feature flags configured correctly

### Git
- [ ] On correct branch
- [ ] Branch up to date with main
- [ ] No merge conflicts
- [ ] Commit messages are clear
```

### 2. Environment Verification

```markdown
### Environment: [staging/production]
- [ ] Environment variables set
- [ ] Secrets/credentials valid
- [ ] Database migrations ready
- [ ] External service dependencies available
```

### 3. Deployment Steps

Provide environment-specific steps:

#### Staging Deployment

```bash
# 1. Ensure tests pass
npm test

# 2. Build the application
npm run build

# 3. Run database migrations (if any)
npm run db:migrate

# 4. Deploy to staging
git push origin staging
# or: npm run deploy:staging

# 5. Verify deployment
curl https://staging.example.com/health
```

#### Production Deployment

```bash
# 1. Final verification
npm test
npm run lint
npm run typecheck

# 2. Create release tag
git tag -a v1.2.3 -m "Release v1.2.3"
git push origin v1.2.3

# 3. Deploy
git push origin main
# or: npm run deploy:production

# 4. Monitor deployment
# Watch logs, metrics, error rates
```

### 4. Post-Deployment Verification

```markdown
## Post-Deploy Verification

### Health Checks
- [ ] Application is responding
- [ ] Health endpoint returns 200
- [ ] Key API endpoints working

### Smoke Tests
- [ ] User can log in
- [ ] Core functionality works
- [ ] No increase in error rates

### Monitoring
- [ ] Check error tracking (Sentry, etc.)
- [ ] Check application logs
- [ ] Check metrics dashboard
- [ ] Check alert systems
```

### 5. Rollback Plan

Always have a rollback ready:

```markdown
## Rollback Procedure

If issues are detected:

### Immediate Rollback
```bash
# Revert to previous version
git revert HEAD
git push origin main

# Or deploy previous tag
git checkout v1.2.2
npm run deploy:production
```

### Database Rollback (if needed)
```bash
# Rollback last migration
npm run db:rollback
```

### Communication
- [ ] Notify team in #deployments
- [ ] Update status page if customer-facing
- [ ] Document incident
```

## Deployment Log Template

```markdown
## Deployment: [Date] [Version]

**Deployer**: [Name]
**Environment**: [staging/production]
**Start Time**: [HH:MM]
**End Time**: [HH:MM]

### Changes Included
- [Feature/fix 1]
- [Feature/fix 2]

### Pre-Deploy Status
- Tests: ✅ Passing
- Build: ✅ Successful
- Migrations: ✅ Ready

### Deployment Status
- [ ] Deployed successfully
- [ ] Health checks passing
- [ ] Smoke tests passing

### Issues Encountered
- [None / Description of issues]

### Rollback Required
- [ ] Yes / [x] No

### Notes
[Any additional observations]
```

## Tips

- Deploy during low-traffic periods
- Have team members available during deploy
- Monitor for at least 15 minutes after deploy
- Document any manual steps needed
- Keep deploys small and frequent
