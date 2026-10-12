<script setup>
import { Head, Link } from '@inertiajs/vue3';

defineProps({
    canLogin: {
        type: Boolean,
    },
    canRegister: {
        type: Boolean,
    },
});
</script>

<template>
    <Head title="Welcome" />

    <div class="landing-page">
        <nav class="top-nav">
            <div class="brand">
                <span class="brand-logo">◈</span>
                <span class="brand-text">ExpenseTracker</span>
            </div>
            <div v-if="canLogin" class="nav-links">
                <Link v-if="$page.props.auth.user" :href="route('dashboard')" class="cancel-button nav-btn">
                    Dashboard
                </Link>
                <template v-else>
                    <Link :href="route('login')" class="cancel-button nav-btn">Log in</Link>
                    <Link v-if="canRegister" :href="route('register')" class="primary-button nav-btn">
                        <span>Get Started</span>
                    </Link>
                </template>
            </div>
        </nav>

        <main class="hero-section">
            <div class="hero-content">
                <p class="eyebrow"><span class="eyebrow-dot"></span> PERSONAL FINANCE</p>
                <h1>Smart tracking for<br /><span>your money.</span></h1>
                <p class="welcome-copy">A clearer view of your expenses starts here. Join today to take control of your spending, organize your transactions, and achieve your financial goals.</p>

                <div class="cta-group" v-if="!$page.props.auth.user">
                    <Link :href="route('register')" class="primary-button hero-btn">
                        <span>Create Free Account</span>
                        <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                            <path d="M5 12h14M13 6l6 6-6 6" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                    </Link>
                </div>
                <div class="cta-group" v-else>
                    <Link :href="route('dashboard')" class="primary-button hero-btn">
                        <span>Go to Dashboard</span>
                        <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                            <path d="M5 12h14M13 6l6 6-6 6" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                    </Link>
                </div>
            </div>

            <div class="welcome-art" aria-hidden="true">
                <div class="art-orbit orbit-one"></div>
                <div class="art-orbit orbit-two"></div>
                <div class="art-icon">
                    <svg viewBox="0 0 64 64" fill="none">
                        <path d="M12 48V34M25 48V24M38 48V30M51 48V14" stroke="currentColor" stroke-width="5" stroke-linecap="round"/>
                        <path d="M8 54H56" stroke="currentColor" stroke-width="2" stroke-linecap="round" opacity=".6"/>
                    </svg>
                </div>
                <span class="art-spark spark-one">✦</span>
                <span class="art-spark spark-two">✧</span>
            </div>
        </main>
    </div>
</template>

<style scoped>
:global(body) {
    background: #f3f7fd;
    margin: 0;
    font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
}

.landing-page {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    padding: 0 26px;
    color: #172b45;
    background:
        radial-gradient(ellipse at 88% 3%, rgba(63, 145, 255, .12), transparent 29rem),
        radial-gradient(ellipse at 2% 42%, rgba(108, 177, 255, .09), transparent 25rem),
        #f3f7fd;
}

.top-nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    max-width: 1400px;
    width: 100%;
    margin: 0 auto;
    padding: 24px 0;
}

.brand {
    display: flex;
    align-items: center;
    gap: 10px;
    color: #132e50;
    font-size: 20px;
    font-weight: 800;
    letter-spacing: -.03em;
}

.brand-logo {
    color: #1677e8;
    font-size: 24px;
}

.nav-links {
    display: flex;
    gap: 12px;
    align-items: center;
}

.nav-btn {
    text-decoration: none;
    padding: 0 20px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
}

.hero-section {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: space-between;
    max-width: 1200px;
    width: 100%;
    margin: 0 auto;
    gap: 60px;
    padding-bottom: 80px;
}

.hero-content {
    max-width: 600px;
}

.eyebrow {
    display: flex;
    align-items: center;
    gap: 9px;
    margin: 0 0 16px;
    color: #1677e8;
    font-size: 12px;
    font-weight: 850;
    letter-spacing: .16em;
}

.eyebrow-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #1681f7;
    box-shadow: 0 0 0 4px rgba(22, 129, 247, .12);
}

.hero-content h1 {
    margin: 0;
    color: #102b4e;
    font-size: clamp(48px, 6vw, 72px);
    font-weight: 800;
    line-height: 1.05;
    letter-spacing: -.05em;
}

.hero-content h1 span {
    color: #1979e8;
}

.welcome-copy {
    margin: 24px 0 36px;
    color: #647894;
    font-size: 18px;
    line-height: 1.6;
}

.cta-group {
    display: flex;
    gap: 16px;
}

.hero-btn {
    text-decoration: none;
    padding: 0 32px;
    min-height: 56px;
    font-size: 16px;
}

/* Reused Buttons from your previous file */
.primary-button {
    border: 0;
    border-radius: 11px;
    background: linear-gradient(110deg, #1269d3, #2189fb);
    color: #fff;
    font-weight: 800;
    cursor: pointer;
    box-shadow: 0 8px 18px rgba(22, 119, 232, .23);
    transition: transform .18s ease, box-shadow .18s ease, filter .18s ease;
}

.primary-button svg {
    width: 19px;
    height: 19px;
    margin-left: 8px;
    transition: transform .18s ease;
}

.primary-button:hover {
    filter: brightness(1.05);
    box-shadow: 0 11px 23px rgba(22, 119, 232, .3);
    transform: translateY(-1px);
}

.primary-button:hover svg {
    transform: translateX(3px);
}

.cancel-button {
    min-height: 43px;
    border: 1px solid #d6e5f6;
    border-radius: 10px;
    background: #f5f9ff;
    color: #38638f;
    font-weight: 700;
    cursor: pointer;
    transition: background .18s ease, border-color .18s ease;
}

.cancel-button:hover {
    border-color: #9dcaff;
    background: #eaf4ff;
}

/* Reused Art Elements */
.welcome-art {
    position: relative;
    display: grid;
    flex: 0 0 300px;
    width: 300px;
    height: 300px;
    place-items: center;
}

.art-orbit {
    position: absolute;
    border: 1.5px solid rgba(22, 119, 232, .2);
    border-radius: 50%;
}

.orbit-one { width: 280px; height: 280px; }
.orbit-two { width: 216px; height: 216px; border-color: rgba(22, 119, 232, .33); }

.art-icon {
    position: relative;
    display: grid;
    width: 140px;
    height: 140px;
    place-items: center;
    border: 1px solid rgba(255, 255, 255, .8);
    border-radius: 36px;
    background: linear-gradient(145deg, #fff, #e5f1ff);
    color: #1979e8;
    box-shadow: 0 20px 50px rgba(25, 121, 232, .17);
    transform: rotate(-5deg);
}

.art-icon svg { width: 80px; height: 80px; }
.art-spark { position: absolute; color: #2585f5; }
.spark-one { top: 30px; right: 20px; font-size: 40px; }
.spark-two { bottom: 30px; left: 10px; color: #73b2ff; font-size: 50px; }

@media (max-width: 900px) {
    .hero-section {
        flex-direction: column-reverse;
        justify-content: center;
        text-align: center;
        gap: 40px;
        padding-top: 40px;
    }
    .eyebrow { justify-content: center; }
    .cta-group { justify-content: center; }
}
</style>