from pathlib import Path

content = r'''<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import { ref, onMounted, computed } from 'vue';
import axios from 'axios';

const expenses = ref([]);
const isEditing = ref(false);
const editingId = ref(null);

const emptyForm = () => ({
    title: '',
    amount: '',
    expense_date: '',
    category: ''
});

const form = ref(emptyForm());

const fetchExpenses = async () => {
    try {
        const response = await axios.get('/expenses');
        expenses.value = response.data;
    } catch (error) {
        console.error('Error fetching data:', error);
    }
};

const resetForm = () => {
    form.value = emptyForm();
    isEditing.value = false;
    editingId.value = null;
};

const submitForm = async () => {
    try {
        if (isEditing.value) {
            await axios.put(`/expenses/${editingId.value}`, form.value);
        } else {
            await axios.post('/expenses', form.value);
        }
        resetForm();
        await fetchExpenses();
    } catch (error) {
        console.error('Submission error:', error);
        // This will display the exact Laravel validation error if the backend rejects it
        if (error.response && error.response.data && error.response.data.message) {
            alert("Could not save: " + error.response.data.message);
        } else {
            alert("An error occurred while saving the expense.");
        }
    }
};

const startEditing = (expense) => {
    editingId.value = expense.id;
    isEditing.value = true;
    form.value = {
        title: expense.title ?? '',
        amount: expense.amount ?? '',
        expense_date: expense.expense_date ?? '',
        category: expense.category ?? ''
    };
    window.scrollTo({ top: 0, behavior: 'smooth' });
};

const deleteExpense = async (id) => {
    if (confirm('Are you sure you want to delete this expense?')) {
        try {
            await axios.delete(`/expenses/${id}`);
            if (editingId.value === id) resetForm();
            await fetchExpenses();
        } catch (error) {
            console.error('Error deleting expense:', error);
            alert('Could not delete the expense.');
        }
    }
};

const totalAmount = computed(() =>
    expenses.value.reduce((sum, expense) => sum + Number.parseFloat(expense.amount || 0), 0).toFixed(2)
);

onMounted(fetchExpenses);
</script>

<template>
    <Head title="Expense Dashboard" />

    <AuthenticatedLayout>
        <template #header>
            <div class="layout-heading">
                <span class="layout-kicker">PERSONAL FINANCE</span>
                <h2>Expense dashboard</h2>
            </div>
        </template>

        <main class="dashboard-page">
            <div class="dashboard-shell">
                <section class="welcome-row">
                    <div>
                        <p class="eyebrow"><span class="eyebrow-dot"></span> YOUR MONEY, IN FOCUS</p>
                        <h1>Take control of<br /><span>your spending.</span></h1>
                        <p class="welcome-copy">A clearer view of your expenses starts here.</p>
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
                </section>

                <section class="total-card">
                    <div class="total-card-decoration decoration-one"></div>
                    <div class="total-card-decoration decoration-two"></div>
                    <div class="total-info">
                        <div class="total-label">
                            <span class="total-icon">
                                <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                    <path d="M4 7.5A2.5 2.5 0 0 1 6.5 5H20v14H6.5A2.5 2.5 0 0 1 4 16.5v-9Z" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/>
                                    <path d="M4 8h13M16 13h4" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>
                                    <circle cx="16" cy="13" r=".8" fill="currentColor"/>
                                </svg>
                            </span>
                            TOTAL EXPENDITURE
                        </div>
                        <p class="total-amount"><span>$</span>{{ totalAmount }}</p>
                        <p class="total-caption">The sum of all your recorded expenses</p>
                    </div>
                    <div class="total-graphic" aria-hidden="true">
                        <div class="graphic-halo"></div>
                        <svg viewBox="0 0 120 100" fill="none">
                            <rect x="12" y="12" width="96" height="76" rx="17" stroke="currentColor" stroke-width="1.5" opacity=".55"/>
                            <path d="M29 68V51M48 68V37M67 68V45M86 68V25" stroke="currentColor" stroke-width="7" stroke-linecap="round"/>
                            <path d="M25 77H94" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" opacity=".7"/>
                        </svg>
                    </div>
                    <div class="total-bottom-line"></div>
                </section>

                <div class="content-grid">
                    <section class="card form-card" :class="{ 'is-editing': isEditing }">
                        <div class="card-heading">
                            <div class="heading-icon" :class="{ 'edit-icon': isEditing }">
                                <svg v-if="!isEditing" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                    <path d="M12 5v14M5 12h14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                                </svg>
                                <svg v-else viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                    <path d="m14 5 5 5M4 20l4.5-1 10-10a2.12 2.12 0 0 0-3-3l-10 10L4 20Z" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                            </div>
                            <div>
                                <p class="section-kicker">{{ isEditing ? 'MAKE A CHANGE' : 'KEEP TRACK' }}</p>
                                <h2>{{ isEditing ? 'Edit expense' : 'Add an expense' }}</h2>
                            </div>
                        </div>
                        <p class="card-description">
                            {{ isEditing ? 'Update the details below and save your changes.' : 'Record a purchase to keep your spending up to date.' }}
                        </p>

                        <form @submit.prevent="submitForm" class="expense-form">
                            <div class="field">
                                <label for="expense-date">Date</label>
                                <div class="input-shell">
                                    <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                        <rect x="3.5" y="5.5" width="17" height="15" rx="2" stroke="currentColor" stroke-width="1.6"/>
                                        <path d="M7.5 3.5v4M16.5 3.5v4M3.5 10h17" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
                                    </svg>
                                    <input id="expense-date" v-model="form.expense_date" type="date" required />
                                </div>
                            </div>

                            <div class="field">
                                <label for="expense-title">Expense name</label>
                                <div class="input-shell">
                                    <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                        <path d="M5 4.5h14A1.5 1.5 0 0 1 20.5 6v12a1.5 1.5 0 0 1-1.5 1.5H5A1.5 1.5 0 0 1 3.5 18V6A1.5 1.5 0 0 1 5 4.5Z" stroke="currentColor" stroke-width="1.6"/>
                                        <path d="M7.5 9h9M7.5 13h6" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
                                    </svg>
                                    <input id="expense-title" v-model="form.title" type="text" placeholder="e.g. Coffee with friends" required />
                                </div>
                            </div>

                            <div class="field">
                                <label for="expense-category">Category</label>
                                <div class="input-shell select-shell">
                                    <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                        <path d="M4 7.5A2.5 2.5 0 0 1 6.5 5H20v14H6.5A2.5 2.5 0 0 1 4 16.5v-9Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/>
                                        <path d="M4 8h13" stroke="currentColor" stroke-width="1.6"/>
                                    </svg>
                                    <select id="expense-category" v-model="form.category" required>
                                        <option disabled value="">Choose a category</option>
                                        <option>Food &amp; Dining</option>
                                        <option>Transportation</option>
                                        <option>Utilities</option>
                                        <option>Entertainment</option>
                                        <option>Shopping</option>
                                        <option>Health &amp; Wellness</option>
                                    </select>
                                </div>
                            </div>

                            <div class="field">
                                <label for="expense-amount">Amount</label>
                                <div class="input-shell amount-shell">
                                    <span class="currency-prefix">$</span>
                                    <input id="expense-amount" v-model="form.amount" type="number" min="0.01" step="0.01" placeholder="0.00" required />
                                </div>
                            </div>

                            <button type="submit" class="primary-button">
                                <span>{{ isEditing ? 'Save changes' : 'Add expense' }}</span>
                                <svg v-if="!isEditing" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                    <path d="M5 12h14M13 6l6 6-6 6" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                                <svg v-else viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                    <path d="m5 12 4 4L19 6" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                            </button>
                            <button v-if="isEditing" type="button" class="cancel-button" @click="resetForm">Cancel editing</button>
                            <p v-else class="form-note"><span></span> Your records stay organized in one place.</p>
                        </form>
                    </section>

                    <section class="card transactions-card">
                        <div class="transactions-top">
                            <div>
                                <p class="section-kicker">YOUR MONEY MOVES</p>
                                <h2>Recent transactions</h2>
                                <p class="card-description">Review and manage the expenses you have recorded.</p>
                            </div>
                            <div class="record-count"><span></span>{{ expenses.length }} {{ expenses.length === 1 ? 'record' : 'records' }}</div>
                        </div>

                        <div v-if="expenses.length > 0" class="table-wrap">
                            <table class="transactions-table">
                                <thead>
                                    <tr>
                                        <th scope="col">Date</th>
                                        <th scope="col">Expense</th>
                                        <th scope="col">Category</th>
                                        <th scope="col" class="amount-heading">Amount</th>
                                        <th scope="col" class="actions-heading">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr v-for="expense in expenses" :key="expense.id" :class="{ 'currently-editing': editingId === expense.id }">
                                        <td class="date-cell">{{ expense.expense_date }}</td>
                                        <td>
                                            <div class="expense-name">
                                                <span class="expense-mini-icon" aria-hidden="true">
                                                    <svg viewBox="0 0 24 24" fill="none">
                                                        <path d="M5 4.5h14A1.5 1.5 0 0 1 20.5 6v12a1.5 1.5 0 0 1-1.5 1.5H5A1.5 1.5 0 0 1 3.5 18V6A1.5 1.5 0 0 1 5 4.5Z" stroke="currentColor" stroke-width="1.5"/>
                                                        <path d="M7.5 9h9M7.5 13h6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
                                                    </svg>
                                                </span>
                                                <span class="expense-title">{{ expense.title }}</span>
                                            </div>
                                        </td>
                                        <td><span class="category-pill">{{ expense.category }}</span></td>
                                        <td class="amount-cell">${{ parseFloat(expense.amount).toFixed(2) }}</td>
                                        <td class="actions-cell">
                                            <button type="button" class="icon-button edit-button" @click="startEditing(expense)" title="Edit expense" aria-label="Edit expense">
                                                <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                                    <path d="m14 5 5 5M4 20l4.5-1 10-10a2.12 2.12 0 0 0-3-3l-10 10L4 20Z" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
                                                </svg>
                                            </button>
                                            <button type="button" class="icon-button delete-button" @click="deleteExpense(expense.id)" title="Delete expense" aria-label="Delete expense">
                                                <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                                    <path d="M4.5 7h15M9 7V4.5h6V7m-8.5 0 .8 12.1a1.5 1.5 0 0 0 1.5 1.4h6.4a1.5 1.5 0 0 0 1.5-1.4L17.5 7M10 10.5v5.5m4-5.5v5.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                                                </svg>
                                            </button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <div v-else class="empty-state">
                            <div class="empty-art" aria-hidden="true">
                                <div class="empty-art-backdrop"></div>
                                <svg viewBox="0 0 64 64" fill="none">
                                    <rect x="15" y="10" width="34" height="44" rx="5" stroke="currentColor" stroke-width="1.8"/>
                                    <path d="M23 22h18M23 30h18M23 38h10" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                                    <path d="m39 46 4 4 8-9" stroke="#1677E8" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                            </div>
                            <h3>No expenses yet</h3>
                            <p>Your transaction list is ready. Add your first expense using the form and it will show up here.</p>
                        </div>

                        <div class="transactions-footer">
                            <span class="footer-star">✦</span>
                            <span>A little clarity goes a long way.</span>
                        </div>
                    </section>
                </div>

                <footer class="dashboard-footer">
                    <span class="footer-logo">◈</span>
                    <span>Spend mindfully. Live freely.</span>
                </footer>
            </div>
        </main>
    </AuthenticatedLayout>
</template>

<style scoped>
:global(body) {
    background: #f3f7fd;
}

.layout-heading {
    display: flex;
    flex-direction: column;
    gap: 4px;
    padding: 2px 0;
}

.layout-kicker {
    color: #1677e8;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: .17em;
}

.layout-heading h2 {
    margin: 0;
    color: #132e50;
    font-size: 21px;
    font-weight: 700;
    letter-spacing: -.035em;
}

.dashboard-page {
    min-height: 100vh;
    padding: 38px 26px 30px;
    color: #172b45;
    background:
        radial-gradient(ellipse at 88% 3%, rgba(63, 145, 255, .12), transparent 29rem),
        radial-gradient(ellipse at 2% 42%, rgba(108, 177, 255, .09), transparent 25rem),
        #f3f7fd;
}

.dashboard-shell {
    max-width: 1400px;
    margin: 0 auto;
}

.welcome-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 24px;
    margin-bottom: 28px;
}

.eyebrow,
.section-kicker {
    display: flex;
    align-items: center;
    gap: 9px;
    margin: 0 0 12px;
    color: #1677e8;
    font-size: 11px;
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

.welcome-row h1 {
    margin: 0;
    color: #102b4e;
    font-size: clamp(36px, 4vw, 51px);
    font-weight: 800;
    line-height: 1.07;
    letter-spacing: -.06em;
}

.welcome-row h1 span {
    color: #1979e8;
}

.welcome-copy {
    margin: 15px 0 0;
    color: #647894;
    font-size: 16px;
    line-height: 1.6;
}

.welcome-art {
    position: relative;
    display: grid;
    flex: 0 0 155px;
    width: 155px;
    height: 145px;
    place-items: center;
    margin-right: 4%;
}

.art-orbit {
    position: absolute;
    border: 1.5px solid rgba(22, 119, 232, .2);
    border-radius: 50%;
}

.orbit-one {
    width: 140px;
    height: 140px;
}

.orbit-two {
    width: 108px;
    height: 108px;
    border-color: rgba(22, 119, 232, .33);
}

.art-icon {
    position: relative;
    display: grid;
    width: 78px;
    height: 78px;
    place-items: center;
    border: 1px solid rgba(255, 255, 255, .8);
    border-radius: 24px;
    background: linear-gradient(145deg, #fff, #e5f1ff);
    color: #1979e8;
    box-shadow: 0 13px 32px rgba(25, 121, 232, .17);
    transform: rotate(-5deg);
}

.art-icon svg {
    width: 50px;
    height: 50px;
}

.art-spark {
    position: absolute;
    color: #2585f5;
}

.spark-one {
    top: 13px;
    right: 13px;
    font-size: 23px;
}

.spark-two {
    bottom: 15px;
    left: 7px;
    color: #73b2ff;
    font-size: 28px;
}

.total-card {
    position: relative;
    display: flex;
    min-height: 220px;
    align-items: center;
    justify-content: space-between;
    overflow: hidden;
    padding: 36px 44px;
    border: 1px solid rgba(255, 255, 255, .55);
    border-radius: 24px;
    background: linear-gradient(115deg, #1269d3 0%, #1682f5 52%, #56a6ff 100%);
    box-shadow: 0 18px 38px rgba(23, 111, 219, .2);
    color: #fff;
}

.total-card-decoration {
    position: absolute;
    border: 1px solid rgba(255, 255, 255, .17);
    border-radius: 50%;
    pointer-events: none;
}

.decoration-one {
    top: -150px;
    right: 12%;
    width: 390px;
    height: 390px;
}

.decoration-two {
    top: -90px;
    right: 19%;
    width: 270px;
    height: 270px;
    background: rgba(255, 255, 255, .035);
}

.total-info {
    position: relative;
    z-index: 2;
}

.total-label {
    display: flex;
    align-items: center;
    gap: 12px;
    color: rgba(255, 255, 255, .85);
    font-size: 12px;
    font-weight: 800;
    letter-spacing: .15em;
}

.total-icon {
    display: grid;
    width: 39px;
    height: 39px;
    place-items: center;
    border: 1px solid rgba(255, 255, 255, .26);
    border-radius: 13px;
    background: rgba(255, 255, 255, .13);
}

.total-icon svg {
    width: 21px;
    height: 21px;
}

.total-amount {
    margin: 18px 0 9px;
    color: #fff;
    font-size: clamp(42px, 5vw, 60px);
    font-weight: 800;
    line-height: 1;
    letter-spacing: -.065em;
    font-variant-numeric: tabular-nums;
}

.total-amount span {
    margin-right: 4px;
    color: #cce5ff;
    font-size: .72em;
    font-weight: 600;
}

.total-caption {
    margin: 0;
    color: rgba(255, 255, 255, .77);
    font-size: 14px;
}

.total-graphic {
    position: relative;
    z-index: 1;
    display: grid;
    width: 190px;
    height: 150px;
    place-items: center;
    color: #fff;
}

.graphic-halo {
    position: absolute;
    width: 145px;
    height: 145px;
    border: 1px solid rgba(255, 255, 255, .22);
    border-radius: 50%;
    background: rgba(255, 255, 255, .06);
}

.total-graphic svg {
    position: relative;
    width: 135px;
    height: 115px;
    padding: 15px;
    border: 1px solid rgba(255, 255, 255, .3);
    border-radius: 25px;
    background: rgba(255, 255, 255, .13);
    backdrop-filter: blur(5px);
    transform: rotate(5deg);
}

.total-bottom-line {
    position: absolute;
    right: 0;
    bottom: 0;
    left: 0;
    height: 4px;
    background: linear-gradient(90deg, #9bceff, #fff, #c4e1ff);
    opacity: .75;
}

.content-grid {
    display: grid;
    grid-template-columns: minmax(320px, .84fr) minmax(0, 1.7fr);
    align-items: stretch;
    gap: 25px;
    margin-top: 26px;
}

.card {
    min-width: 0;
    border: 1px solid #e1eaf6;
    border-radius: 20px;
    background: #fff;
    box-shadow: 0 10px 30px rgba(29, 67, 117, .055);
}

.form-card {
    align-self: start;
    padding: 29px 27px 23px;
    transition: border-color .2s ease, box-shadow .2s ease;
}

.form-card.is-editing {
    border-color: #77b4ff;
    box-shadow: 0 10px 30px rgba(22, 119, 232, .12), 0 0 0 3px rgba(22, 119, 232, .06);
}

.card-heading {
    display: flex;
    align-items: center;
    gap: 14px;
}

.heading-icon {
    display: grid;
    flex: 0 0 48px;
    width: 48px;
    height: 48px;
    place-items: center;
    border: 1px solid #cfe4ff;
    border-radius: 15px;
    background: linear-gradient(145deg, #f0f7ff, #e2efff);
    color: #1677e8;
}

.heading-icon.edit-icon {
    border-color: #b6d8ff;
    background: #dcecff;
}

.heading-icon svg {
    width: 23px;
    height: 23px;
}

.section-kicker {
    margin-bottom: 5px;
    font-size: 10px;
    letter-spacing: .14em;
}

.card h2 {
    margin: 0;
    color: #142f52;
    font-size: 21px;
    font-weight: 800;
    letter-spacing: -.04em;
}

.card-description {
    margin: 13px 0 25px;
    color: #6e819a;
    font-size: 14px;
    line-height: 1.65;
}

.expense-form {
    display: flex;
    flex-direction: column;
    gap: 18px;
}

.field label {
    display: block;
    margin-bottom: 9px;
    color: #314964;
    font-size: 14px;
    font-weight: 750;
}

.input-shell {
    position: relative;
    display: flex;
    min-width: 0;
    align-items: center;
}

.input-shell > svg {
    position: absolute;
    z-index: 1;
    left: 14px;
    width: 19px;
    height: 19px;
    color: #7d9abc;
    pointer-events: none;
}

.input-shell input,
.input-shell select {
    display: block;
    width: 100%;
    min-width: 0;
    height: 51px;
    padding: 0 14px 0 44px;
    border: 1.5px solid #dbe6f3;
    border-radius: 11px;
    outline: none;
    background: #f9fbfe;
    color: #183452;
    font-size: 14px;
    transition: border-color .18s ease, box-shadow .18s ease, background .18s ease;
}

.input-shell input::placeholder {
    color: #9aabc0;
}

.input-shell input:focus,
.input-shell select:focus {
    border-color: #2685f5;
    background: #fff;
    box-shadow: 0 0 0 4px rgba(38, 133, 245, .12);
}

.input-shell select {
    appearance: none;
    padding-right: 40px;
    cursor: pointer;
}

.select-shell::after {
    position: absolute;
    right: 16px;
    width: 8px;
    height: 8px;
    border-right: 2px solid #7891ad;
    border-bottom: 2px solid #7891ad;
    content: '';
    pointer-events: none;
    transform: translateY(-2px) rotate(45deg);
}

.amount-shell .currency-prefix {
    position: absolute;
    left: 16px;
    z-index: 1;
    color: #1677e8;
    font-size: 17px;
    font-weight: 800;
}

.amount-shell input {
    padding-left: 36px;
    font-variant-numeric: tabular-nums;
}

.primary-button {
    display: flex;
    min-height: 51px;
    align-items: center;
    justify-content: center;
    gap: 10px;
    margin-top: 2px;
    border: 0;
    border-radius: 11px;
    background: linear-gradient(110deg, #1269d3, #2189fb);
    color: #fff;
    font-size: 15px;
    font-weight: 800;
    cursor: pointer;
    box-shadow: 0 8px 18px rgba(22, 119, 232, .23);
    transition: transform .18s ease, box-shadow .18s ease, filter .18s ease;
}

.primary-button svg {
    width: 19px;
    height: 19px;
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
    font-size: 14px;
    font-weight: 700;
    cursor: pointer;
    transition: background .18s ease, border-color .18s ease;
}

.cancel-button:hover {
    border-color: #9dcaff;
    background: #eaf4ff;
}

.form-note {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    margin: 0;
    color: #7f92a8;
    font-size: 12px;
}

.form-note span {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: #2189fb;
}

.transactions-card {
    display: flex;
    min-height: 500px;
    flex-direction: column;
    overflow: hidden;
}

.transactions-top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 18px;
    padding: 29px 29px 24px;
    border-bottom: 1px solid #e9f0f8;
}

.transactions-top .card-description {
    margin: 9px 0 0;
}

.record-count {
    display: inline-flex;
    flex-shrink: 0;
    align-items: center;
    gap: 8px;
    padding: 9px 12px;
    border: 1px solid #d9eaff;
    border-radius: 9px;
    background: #f1f7ff;
    color: #236fca;
    font-size: 12px;
    font-weight: 800;
}

.record-count span {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: #2585f5;
    box-shadow: 0 0 0 3px rgba(37, 133, 245, .12);
}

.table-wrap {
    width: 100%;
    overflow-x: auto;
}

.transactions-table {
    width: 100%;
    border-collapse: collapse;
    text-align: left;
}

.transactions-table thead {
    background: #f5f9ff;
}

.transactions-table th {
    padding: 16px 15px;
    color: #6c83a0;
    font-size: 11px;
    font-weight: 850;
    letter-spacing: .09em;
    text-transform: uppercase;
    white-space: nowrap;
}

.transactions-table th:first-child,
.transactions-table td:first-child {
    padding-left: 28px;
}

.transactions-table th:last-child,
.transactions-table td:last-child {
    padding-right: 24px;
}

.transactions-table tbody tr {
    border-bottom: 1px solid #edf2f8;
    transition: background .18s ease;
}

.transactions-table tbody tr:last-child {
    border-bottom: 0;
}

.transactions-table tbody tr:hover,
.transactions-table tbody tr.currently-editing {
    background: #f2f8ff;
}

.transactions-table td {
    padding: 17px 15px;
    color: #526982;
    font-size: 13px;
    white-space: nowrap;
}

.date-cell {
    color: #6e829a !important;
    font-variant-numeric: tabular-nums;
}

.expense-name {
    display: flex;
    min-width: 135px;
    align-items: center;
    gap: 11px;
}

.expense-mini-icon {
    display: grid;
    flex: 0 0 35px;
    width: 35px;
    height: 35px;
    place-items: center;
    border: 1px solid #d9eaff;
    border-radius: 10px;
    background: #f0f7ff;
    color: #247fe8;
}

.expense-mini-icon svg {
    width: 17px;
    height: 17px;
}

.expense-title {
    max-width: 190px;
    overflow: hidden;
    color: #1c3858;
    font-size: 13px;
    font-weight: 750;
    text-overflow: ellipsis;
}

.category-pill {
    display: inline-flex;
    align-items: center;
    padding: 7px 10px;
    border: 1px solid #d8eaff;
    border-radius: 8px;
    background: #f1f7ff;
    color: #246fc3;
    font-size: 11px;
    font-weight: 750;
}

.amount-heading,
.amount-cell {
    text-align: right;
}

.amount-cell {
    color: #153d6b !important;
    font-size: 14px !important;
    font-weight: 850;
    font-variant-numeric: tabular-nums;
}

.actions-heading {
    min-width: 100px;
    text-align: center;
}

.actions-cell {
    text-align: center;
}

.icon-button {
    display: inline-grid;
    width: 34px;
    height: 34px;
    place-items: center;
    margin: 0 2px;
    border: 1px solid transparent;
    border-radius: 9px;
    background: transparent;
    cursor: pointer;
    transition: color .18s ease, background .18s ease, border-color .18s ease, transform .18s ease;
}

.icon-button svg {
    width: 18px;
    height: 18px;
}

.edit-button {
    color: #247fe8;
}

.edit-button:hover {
    border-color: #c8e1ff;
    background: #e4f1ff;
    transform: translateY(-1px);
}

.delete-button {
    color: #8da0b6;
}

.delete-button:hover {
    border-color: #ffd9d9;
    background: #fff0f0;
    color: #d34e5a;
    transform: translateY(-1px);
}

.icon-button:focus-visible,
.primary-button:focus-visible,
.cancel-button:focus-visible {
    outline: 3px solid rgba(22, 119, 232, .25);
    outline-offset: 2px;
}

.empty-state {
    display: flex;
    flex: 1;
    min-height: 300px;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 35px 24px;
    text-align: center;
}

.empty-art {
    position: relative;
    display: grid;
    width: 100px;
    height: 100px;
    place-items: center;
    margin-bottom: 18px;
}

.empty-art-backdrop {
    position: absolute;
    width: 90px;
    height: 90px;
    border: 1px solid #d9eaff;
    border-radius: 28px;
    background: linear-gradient(145deg, #f6faff, #e6f2ff);
    transform: rotate(-7deg);
}

.empty-art svg {
    position: relative;
    width: 62px;
    height: 62px;
    color: #77a7dd;
}

.empty-state h3 {
    margin: 0 0 9px;
    color: #18395e;
    font-size: 19px;
    font-weight: 850;
    letter-spacing: -.03em;
}

.empty-state p {
    max-width: 320px;
    margin: 0;
    color: #71869f;
    font-size: 14px;
    line-height: 1.8;
}

.transactions-footer {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-top: auto;
    padding: 15px 28px;
    border-top: 1px solid #e9f0f8;
    color: #7d91a8;
    font-size: 12px;
}

.footer-star {
    color: #2585f5;
    font-size: 15px;
}

.dashboard-footer {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 9px;
    padding: 28px 0 4px;
    color: #7e91a8;
    font-size: 13px;
    font-weight: 600;
}

.footer-logo {
    color: #1677e8;
    font-size: 18px;
}

@media (max-width: 1100px) {
    .content-grid {
        grid-template-columns: minmax(290px, .9fr) minmax(0, 1.4fr);
        gap: 18px;
    }

    .form-card {
        padding: 24px 20px 21px;
    }

    .transactions-top {
        padding-right: 22px;
        padding-left: 22px;
    }

    .transactions-table th,
    .transactions-table td {
        padding-right: 11px;
        padding-left: 11px;
    }

    .transactions-table th:first-child,
    .transactions-table td:first-child {
        padding-left: 19px;
    }
}

@media (max-width: 800px) {
    .dashboard-page {
        padding: 30px 18px 24px;
    }

    .welcome-row h1 {
        font-size: 42px;
    }

    .welcome-art {
        flex-basis: 115px;
        width: 115px;
        height: 115px;
        margin-right: 0;
    }

    .orbit-one {
        width: 112px;
        height: 112px;
    }

    .orbit-two {
        width: 88px;
        height: 88px;
    }

    .art-icon {
        width: 65px;
        height: 65px;
        border-radius: 20px;
    }

    .art-icon svg {
        width: 42px;
        height: 42px;
    }

    .content-grid {
        grid-template-columns: 1fr;
        gap: 20px;
    }

    .form-card {
        padding: 27px 25px 23px;
    }

    .transactions-card {
        min-height: 430px;
    }
}

@media (max-width: 520px) {
    .dashboard-page {
        padding: 25px 12px 20px;
    }

    .welcome-row {
        align-items: flex-start;
        gap: 5px;
        margin-bottom: 22px;
    }

    .welcome-row h1 {
        font-size: 34px;
    }

    .welcome-copy {
        max-width: 250px;
        font-size: 14px;
    }

    .eyebrow {
        font-size: 9px;
    }

    .welcome-art {
        flex-basis: 68px;
        width: 68px;
        height: 75px;
        margin-top: 22px;
    }

    .orbit-one {
        width: 68px;
        height: 68px;
    }

    .orbit-two {
        width: 52px;
        height: 52px;
    }

    .art-icon {
        width: 45px;
        height: 45px;
        border-radius: 14px;
    }

    .art-icon svg {
        width: 30px;
        height: 30px;
    }

    .spark-one {
        top: -2px;
        right: 0;
        font-size: 16px;
    }

    .spark-two {
        bottom: -1px;
        left: -2px;
        font-size: 20px;
    }

    .total-card {
        min-height: 170px;
        padding: 24px 20px;
        border-radius: 18px;
    }

    .total-label {
        gap: 8px;
        font-size: 9px;
        letter-spacing: .1em;
    }

    .total-icon {
        width: 31px;
        height: 31px;
        border-radius: 10px;
    }

    .total-icon svg {
        width: 17px;
        height: 17px;
    }

    .total-amount {
        font-size: 40px;
    }

    .total-caption {
        max-width: 210px;
        font-size: 12px;
        line-height: 1.6;
    }

    .total-graphic {
        width: 60px;
        height: 80px;
        margin-right: -10px;
    }

    .total-graphic svg {
        width: 58px;
        height: 64px;
        padding: 7px;
        border-radius: 15px;
    }

    .graphic-halo {
        width: 65px;
        height: 65px;
    }

    .form-card {
        padding: 23px 17px 20px;
    }

    .card h2 {
        font-size: 20px;
    }

    .transactions-top {
        align-items: flex-start;
        flex-direction: column;
        gap: 14px;
        padding: 23px 18px 19px;
    }

    .transactions-top .card-description {
        margin-top: 7px;
    }

    .transactions-table {
        min-width: 690px;
    }

    .transactions-footer {
        padding-right: 18px;
        padding-left: 18px;
    }
}

@media (prefers-reduced-motion: reduce) {
    *,
    *::before,
    *::after {
        scroll-behavior: auto !important;
        transition-duration: .01ms !important;
        animation-duration: .01ms !important;
        animation-iteration-count: 1 !important;
    }
}
</style>
'''

path = Path("/mnt/data/Dashboard.vue")
path.write_text(content, encoding="utf-8")
print(f"Created updated {path} ({len(content.splitlines())} lines)")
