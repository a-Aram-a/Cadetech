document.addEventListener('DOMContentLoaded', function () {
    script()
})

function script() {
    if (location.pathname == '/services') {
        const sevicesItems = document.querySelectorAll('.view-napravleniya-deyatelnosti .views-row')
        for (let i = 0; i < sevicesItems.length; i++) {
            sevicesItems[i].addEventListener('click', function () {
                sevicesItems[i].classList.toggle('more')
            })
        }
    }
}