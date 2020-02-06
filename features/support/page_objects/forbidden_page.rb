class ForbiddenPage < BasePage
  element :header, 'h1', text: 'You are accessing the intranet from outside the MoJ network.'
  element :error_403, 'p', text: 'Forbidden - 403'
end
