"""Authentication form component."""

def:pub AuthForm(
    isSignup: bool,
    username: str,
    password: str,
    error: str,
    loading: bool,
    onUsernameChange: any,
    onPasswordChange: any,
    onSubmit: any,
    onToggleMode: any
) -> any {
    return
        <div className="auth-container">
            <div className="bg-glow bg-glow-one"></div>
            <div className="bg-glow bg-glow-two"></div>
            <div className="auth-card">
                <p className="eyebrow">Welcome to Orbit</p>
                <h1 className="auth-title">TaskFlow Orbit</h1>
                <p className="auth-subtitle">
                    {("Create your pilot account" if isSignup else "Sign in to continue")}
                </p>
                {(
                    <div className="auth-error">{error}</div>
                ) if error else None}
                <form onSubmit={onSubmit}>
                    <div className="form-field">
                        <label className="form-label">Username</label>
                        <input
                            type="text"
                            value={username}
                            onChange={onUsernameChange}
                            placeholder="e.g. orbit_operator"
                            className="auth-input"
                        />
                    </div>
                    <div className="form-field-last">
                        <label className="form-label">Password</label>
                        <input
                            type="password"
                            value={password}
                            onChange={onPasswordChange}
                            placeholder="At least 4 characters"
                            className="auth-input"
                        />
                    </div>
                    <button type="submit" disabled={loading} className="auth-submit">
                        {("Working..." if loading else ("Create Account" if isSignup else "Sign In"))}
                    </button>
                </form>
                <div className="auth-toggle">
                    <span className="auth-toggle-text">
                        {(
                            "Already registered? "
                            if isSignup
                            else "Need an account? "
                        )}
                    </span>
                    <button
                        type="button"
                        onClick={onToggleMode}
                        className="auth-toggle-btn"
                    >
                        {("Sign In" if isSignup else "Sign Up")}
                    </button>
                </div>
            </div>
        </div>;
}
